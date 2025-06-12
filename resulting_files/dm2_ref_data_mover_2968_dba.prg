CREATE PROGRAM dm2_ref_data_mover_2968:dba
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
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE del_chg_log_smry(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
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
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET sat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
        tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
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
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->tbl_qual[
        exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
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
    SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].custom_script,
     ":Multiple values returned with unique indicator query.")
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
        SET iur_del_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
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
        SET iur_del_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
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
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
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
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
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
     SET no_delete = 1
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
      "This table is marked as insert only, so this row will not be updated.")
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table"
       )
      SET nodelete_ind = 1
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
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].update_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as update only, so this row will not be inserted.")
     RETURN(0)
    ELSE
     SET ins_ind = 1
     SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].table_name," dc set ")
     SET drdm_parser_cnt = 2
     FOR (insert_loop = 1 TO iur_perm_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB"
       ))
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
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8")
         )
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
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," ",
       drdm_chg->log[drdm_log_loop].pk_where,")")
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
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
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
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
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
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
    "", " ")))
     SET to_val = "BADLOG"
    ELSE
     SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
      col_qual[dt_temp_col_cnt].root_entity_name)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
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
   DECLARE sbr_f_value = vc
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
    FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
       SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
      ENDIF
    ENDFOR
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found")
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
   DECLARE sbr_tname_flex = vc
   SET drdm_any_translated = 1
   SET dm_err->eproc = concat("Updating DM_CHG_LOG Table ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET drdm_parser->statement[1].frag = concat("select into 'nl:' from ",sbr_tname_flex,
    " d where log_id = drdm_chg->log[drdm_log_loop].log_id detail update_cnt = d.updt_cnt",
    " with nocounter go")
   CALL parse_statements(1)
   IF ((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt))
    CALL parser(concat("update into ",sbr_tname_flex,
      " d set d.log_type = sbr_log_type, d.updt_dt_tm = cnvtdatetime(curdate, curtime3), "),0)
    CALL parser(concat(" d.updt_cnt = d.updt_cnt + 1 ",
      " where d.log_id = drdm_chg->log[drdm_log_loop].log_id go"),1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not delete log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop]
       .log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    ROLLBACK
    CALL merge_audit("FAILREASON",nodelete_msg)
    COMMIT
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE del_chg_log_smry(sbr_table_name,sbr_log_type,sbr_target_id)
   DECLARE sbr_chg_log_smry = vc
   SET sbr_chg_log_smry = concat(dm2_ref_data_doc->pre_link_name,"DM_CHG_LOG_SMRY",dm2_ref_data_doc->
    post_link_name)
   SET dm_err->eproc = concat("Updating DM_CHG_LOG_SMRY Table ",cnvtstring(drdm_chg->log[
     drdm_log_loop].log_id))
   CALL parser(concat("update into ",sbr_chg_log_smry," d set d.row_count=d.row_count + 1, "),0)
   CALL parser(
    " d.updt_cnt=d.updt_cnt + 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3) where d.table_name = ",
    0)
   CALL parser(concat('"',sbr_table_name,'" and d.target_env_id = ',cnvtstring(sbr_target_id),
     " and d.log_type = sbr_log_type go"),1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("Insert into ",sbr_chg_log_smry," d set d.row_count = 1, d.table_name = "),0)
     CALL parser(concat('"',sbr_table_name,'", d.target_env_id = ',cnvtstring(sbr_target_id),
       ", d.log_type = sbr_log_type, "),0)
     CALL parser(" d.updt_cnt = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3) go",1)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
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
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1)
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    UPDATE  FROM (parser(imt_except_tab) d)
     SET d.log_type = "BADTRN"
     WHERE d.table_name=sbr_table
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
      AND d.from_value=sbr_from
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
    IF (curqual=0)
     INSERT  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
       tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
       d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
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
    ROLLBACK
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
    COMMIT
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
       CALL echo(concat(
         "DM_TABLES_DOC is missing a table that is in DTABLE or the following table is activity: ",
         p_e_name))
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
       ELSE
        SET p_e_where_str = concat("d.table_name = '",p_e_name,"' and d.column_name = '",p_e_col,"'")
        SELECT INTO "nl:"
         d.root_entity_name
         FROM dm_columns_doc d
         WHERE parser(p_e_where_str)
         DETAIL
          r_e_name = d.root_entity_name
         WITH nocounter
        ;end select
        IF (curqual=0)
         CALL echo("Information not found in dm_columns_doc for parent_entity_col")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
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
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    CALL parser(concat("set ma_log_id = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
      "->log_id go"),1)
    SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
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
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   ROLLBACK
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
      SET d.log_type = "NOXLAT", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
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
      COMMIT
     ENDIF
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER"))
      RETURN(except_log_type)
     ENDIF
    ENDIF
   ENDIF
   RETURN("NOXLAT")
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   ROLLBACK
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
 SUBROUTINE orphan_child_tab(sbr_table_name)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
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
   SELECT INTO "NL:"
    FROM (parser(oct_excptn_tab) d)
    WHERE d.table_name=sbr_table_name
     AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
     AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.from_value=oct_pk_value
    WITH nocounter
   ;end select
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
      d.from_value = oct_pk_value, d.log_type = "ORPHAN"
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
     SET d.log_type = "ORPHAN"
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
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
  IF (cursys="AIX")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ELSEIF (cursys="WIN")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSE
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
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
 DECLARE dm2_disp_file(ddf_fname=vc,ddf_desc=vc) = i2
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
   IF (cursys IN ("AIX", "WIN"))
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
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (cursys)
      OF "AIX":
       SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (currdb="DB2UDB")
     SET posx = 1
     SET sql_warn_ind = false
     WHILE (posx < size(dm_err->errtext))
      SET posx = findstring("SQL",dm_err->errtext,posx)
      IF (posx > 0)
       SET posx = (posx+ 7)
       IF (isnumeric(substring(posx,1,dm_err->errtext)) > 0)
        SET posx = (posx+ 1)
        IF (isnumeric(substring(posx,1,dm_err->errtext))=0)
         CASE (substring(posx,1,dm_err->errtext))
          OF "W":
           SET sql_warn_ind = true
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit warning encountered")
           ENDIF
          OF "E":
           SET sql_warn_ind = false
           SET posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit E error encountered")
           ENDIF
          OF "N":
           SET sql_warn_ind = false
           SET posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit N error encountered")
           ENDIF
          ELSE
           IF ((dm_err->debug_flag > 0))
            CALL echo("Not W, E, N")
           ENDIF
         ENDCASE
        ENDIF
       ELSE
        CASE (substring(posx,1,dm_err->errtext))
         OF "W":
          SET sql_warn_ind = true
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit warning encountered")
          ENDIF
         OF "E":
          SET sql_warn_ind = false
          SET posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit E error encountered")
          ENDIF
         OF "N":
          SET sql_warn_ind = false
          SET posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit N error encountered")
          ENDIF
         ELSE
          IF ((dm_err->debug_flag > 0))
           CALL echo("Not W, E, N")
          ENDIF
        ENDCASE
       ENDIF
      ELSE
       SET posx = size(dm_err->errtext)
      ENDIF
     ENDWHILE
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
   IF (textlen(concat(sbr_fprefix,sbr_fext)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    SET dm_err->eproc = concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
     sbr_fext)
    SET dm_err->user_action =
    "Please enter a file prefix and extension that does not exceed a length of 24."
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=1)
    WHILE (fini=0)
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
      SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
      IF (findfile(fname)=0)
       SET fini = 1
      ENDIF
    ENDWHILE
    IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
      sbr_fext))=1)
     SET guf_return_val = 0
    ENDIF
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
    AND textlen(sbr_dlogfile) <= 30)
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
   ELSE
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
    AND trim(sbr_logfile) != ""
    AND textlen(sbr_logfile) <= 30)
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
    IF ((dm_err->debug_flag > 1))
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
   IF ( NOT (sbr_dsa_flag IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid autocommit flag"
    SET dm_err->eproc = "Setting autocommit indicator"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (currdbhandle > " ")
     IF (sbr_dsa_flag=1)
      IF (dm2_push_cmd("rdb set autocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set inlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ELSE
      IF (dm2_push_cmd("rdb set noautocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set noinlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
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
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
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
   FROM dm2_user_tab_columns dutc,
    dtable dt
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.table_name=dt.table_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual=0)
    RETURN("N")
   ELSE
    RETURN("F")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SELECT INTO "nl:"
    FROM dm2_user_tab_cols dutc,
     dtable dt
    WHERE dutc.table_name=trim(cnvtupper(dtace_table_name))
     AND dutc.table_name=dt.table_name
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual=0)
     SET dtace_found_ind = 0
    ELSE
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_disp_file(ddf_fname,ddf_desc)
   SET dm_err->eproc = concat("Displaying ",ddf_desc)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 value(ddf_fname)
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
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_get_env_data(dged_use_admin_ind=i2,dged_environment_id=f8(ref)) = i2
 DECLARE dm2_get_dbase_name(dgdn_name_out=vc(ref)) = i2
 DECLARE dm2_get_rdbms_version() = i2
 DECLARE dm2ceil(dc_numin) = null
 DECLARE dm2floor(dc_numin) = null
 DECLARE val_user_privs(sbr_dummy_param=i2) = i2
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
  CASE (currdb)
   OF "ORACLE":
    SET dm2_rdbms_version->level1 = 0
    SET dm2_rdbms_version->level2 = 0
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "DB2":
    SET dm2_rdbms_version->level1 = 8
    SET dm2_rdbms_version->level2 = 1
    SET dm2_rdbms_version->level3 = 2
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "SQLSRV":
    SET dm2_rdbms_version->level1 = 2000
    SET dm2_rdbms_version->level2 = 8
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 194
    SET dm2_rdbms_version->level5 = 0
  ENDCASE
 ENDIF
 SUBROUTINE dm2_get_dbase_name(dgdn_name_out)
  IF (validate(currdbname," ")=" "
   AND currdb="ORACLE")
   SET dm_err->eproc = "Retrieving database name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgdn_name_out = v.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
  ELSE
   SET dgdn_name_out = currdbname
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_env_data(dged_use_admin_ind,dged_environment_id)
   DECLARE dged_local_env_id = f8 WITH protect, noconstant(0.0)
   IF ( NOT (dged_use_admin_ind IN (1, 0)))
    SET dged_use_admin_ind = 0
   ENDIF
   SET dm_err->eproc = "Retrieving environment id."
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dged_use_admin_ind=0)
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
    ELSE
     FROM dm_info d,
      dm_environment de
     PLAN (d
      WHERE d.info_domain="DATA MANAGEMENT"
       AND d.info_name="DM_ENV_ID")
      JOIN (de
      WHERE d.info_number=de.environment_id)
    ENDIF
    INTO "nl:"
    DETAIL
     dged_local_env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve environment data."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    SET dged_environment_id = dged_local_env_id
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dm2_rdbms_version->version = p.version
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
 SUBROUTINE dm2ceil(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = dc_numin_whole
     ELSE
      SET dc_numin_save = (dc_numin_whole+ 1)
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2floor(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = (dc_numin_whole - 1)
     ELSE
      SET dc_numin_save = dc_numin_whole
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 SUBROUTINE val_user_privs(sbr_dummy_param)
   SET dm_err->eproc = "Retrieving CCL user data from duaf."
   SELECT INTO "nl:"
    d.group
    FROM duaf d
    WHERE cnvtupper(d.user_name)=cnvtupper(curuser)
     AND d.group=0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND cnvtupper(curuser) != "P30INS")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user privileges"
    CALL disp_msg(concat("Current user, ",curuser,", does not have CCL DBA privileges required",
      " to run this program. Please contact your system administrator."),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_check_log_for_errors(dclfe_op_id=f8,dclfe_oper_logfile=vc,dclfe_force_load_ind=i2,
  dclfe_err_ind=i2(ref)) = i2
 DECLARE dir_load_mixed_table_data(dlmtd_force_load_ind=i2) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dir_get_dmp_log_loc(dgdll_op_id=f8,dgdll_dmp_loc_out=vc(ref)) = i2
 DECLARE dir_load_ref_table_data(force_load_ind=i2) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 IF ((validate(dm2_priority_group_matrix->cnt,- (1))=- (1)))
  FREE RECORD dm2_priority_group_matrix
  RECORD dm2_priority_group_matrix(
    1 cnt = i2
    1 priority_group[*]
      2 group_name = vc
      2 priority_from_range = i4
      2 priority_to_range = i4
      2 group_prefix = c10
  )
  SET dm2_priority_group_matrix->cnt = 0
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE TABLES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 0
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  100
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ct"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE INDEXES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 199
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  400
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ci"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE CONSTRAINTS"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 399
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  500
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "cc"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "RUN UTILITIES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 699
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  800
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ru"
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
 IF (validate(dir_clin_copy_data->process,"x")="x"
  AND validate(dir_clin_copy_data->process,"y")="y")
  FREE RECORD dir_clin_copy_data
  RECORD dir_clin_copy_data(
    1 process = vc
    1 export_location = vc
    1 schema_date = dq8
    1 ref_par_file_cnt = i2
    1 summary_par_file_name = vc
    1 mixed_tables_parfile_name = vc
    1 ref_parfile_prefix = vc
    1 ind_mixed_parfile_prefix = vc
    1 exp_file_prefix = vc
    1 imp_file_prefix = vc
    1 export_rpt_name = vc
    1 import_rpt_name = vc
  )
  SET dir_clin_copy_data->process = "DM2NOTSET"
  SET dir_clin_copy_data->export_location = "DM2NOTSET"
  SET dir_clin_copy_data->ref_par_file_cnt = 0
  SET dir_clin_copy_data->summary_par_file_name = "dm2_ref_parfile_summary.dat"
  SET dir_clin_copy_data->mixed_tables_parfile_name = "dm2_mixed_tables.par"
  SET dir_clin_copy_data->ref_parfile_prefix = "dm2_reference_tables_"
  SET dir_clin_copy_data->ind_mixed_parfile_prefix = "dm2_mixtbl_"
  SET dir_clin_copy_data->exp_file_prefix = "exp_v500"
  SET dir_clin_copy_data->imp_file_prefix = "imp_v500"
  SET dir_clin_copy_data->exp_file_prefix = "dm2_export"
  SET dir_clin_copy_data->imp_file_prefix = "dm2_import"
 ENDIF
 IF (validate(dir_mixed_tables_data->cnt,1)=1
  AND validate(dir_mixed_tables_data->cnt,2)=2)
  FREE RECORD dir_mixed_tables_data
  RECORD dir_mixed_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 table_suffix = vc
      2 where_clause_cnt = i2
      2 qual[*]
        3 process_type = vc
        3 data_type = vc
        3 where_clause = vc
      2 prefix = vc
  )
  SET dir_mixed_tables_data->cnt = 0
 ENDIF
 IF (validate(dir_ignored_errors->cnt,1)=1
  AND validate(dir_ignored_errors->cnt,2)=2)
  FREE RECORD dir_ignored_errors
  RECORD dir_ignored_errors(
    1 cnt = i4
    1 dir_ignorable_errfile = vc
    1 qual[*]
      2 error = vc
  )
  SET dir_ignored_errors->cnt = 0
  SET dir_ignored_errors->dir_ignorable_errfile = "dm2_ignorable_errors.dat"
 ENDIF
 IF (validate(dir_errors_encountered->cmd_cnt,1)=1
  AND validate(dir_errors_encountered->cmd_cnt,2)=2)
  FREE RECORD dir_errors_encountered
  RECORD dir_errors_encountered(
    1 cmd_cnt = i4
    1 qual[*]
      2 dee_op_id = f8
      2 error_cnt = i4
      2 logfile_name = vc
      2 qual[*]
        3 error = vc
        3 error_desc = vc
  )
  SET dir_errors_encountered->cmd_cnt = 0
 ENDIF
 IF (validate(dir_ref_tables_data->cnt,1)=1
  AND validate(dir_ref_tables_data->cnt,2)=2)
  FREE RECORD dir_ref_tables_data
  RECORD dir_ref_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET dir_ref_tables_data->cnt = 0
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
 SUBROUTINE dir_get_dmp_log_loc(dgdll_op_id,dgdll_dmp_loc_out)
   DECLARE dgdll_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Find logfile for OP_ID:",build(dgdll_op_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.op_id=dgdll_op_id
    DETAIL
     dgdll_strt_pt = (findstring("log=",d.operation,1)+ 4), dgdll_end_pt = findstring(" ",d.operation,
      dgdll_strt_pt), dgdll_dmp_loc_out = substring(dgdll_strt_pt,(dgdll_end_pt - dgdll_strt_pt),d
      .operation)
     IF ((dm_err->debug_flag > 2))
      CALL echo(d.operation),
      CALL echo(dgdll_strt_pt),
      CALL echo(dgdll_end_pt),
      CALL echo(dgdll_dmp_loc_out)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgdll_dmp_loc_out = "NOT_VALID_OP_ID"
   ELSE
    IF (dgdll_dmp_loc_out > " ")
     IF (findfile(dgdll_dmp_loc_out)=0)
      SET dgdll_dmp_loc_out = concat("NO_FILE_IN_OS:",dgdll_dmp_loc_out)
     ENDIF
    ELSE
     SET dgdll_dmp_loc_out = "NO_FILE_IN_COMMAND"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_ref_table_data(force_load_ind)
   DECLARE dlrtd_mix_ndx = i4 WITH protect, noconstant(0)
   IF ((dir_ref_tables_data->cnt > 0)
    AND force_load_ind=0)
    SET dm_err->eproc = "Skipping load of reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dir_load_mixed_table_data(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading reference table list."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dir_ref_tables_data->cnt = 0
   SET stat = alterlist(dir_ref_tables_data->tbl,dir_ref_tables_data->cnt)
   SELECT INTO "nl:"
    dut.table_name
    FROM dm_tables_doc dtd,
     dm2_user_tables dut
    PLAN (dtd
     WHERE dtd.table_name=dtd.full_table_name
      AND dtd.reference_ind=1)
     JOIN (dut
     WHERE dut.table_name=dtd.table_name)
    ORDER BY dut.table_name
    DETAIL
     IF (locateval(dlrtd_mix_ndx,1,value(dir_mixed_tables_data->cnt),dut.table_name,
      dir_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name)=0)
      dir_ref_tables_data->cnt = (dir_ref_tables_data->cnt+ 1)
      IF (mod(dir_ref_tables_data->cnt,2000)=1)
       stat = alterlist(dir_ref_tables_data->tbl,(dir_ref_tables_data->cnt+ 1999))
      ENDIF
      dir_ref_tables_data->tbl[dir_ref_tables_data->cnt].table_name = dut.table_name
     ELSE
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(dut.table_name),
        " is a mixed table and not loaded into Reference listing."))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dir_ref_tables_data->tbl,dir_ref_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dir_ref_tables_data->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking count of reference tables."
    SET dm_err->emsg = "No reference tables found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_ref_tables_data)
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
 SUBROUTINE dir_check_log_for_errors(dclfe_op_id,dclfe_oper_logfile,dclfe_force_load_ind,
  dclfe_err_ind)
   DECLARE dclfe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_type = vc WITH protect, noconstant("")
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_add_cmd = i2 WITH protect, noconstant(1)
   DECLARE dclfe_err_cnt = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Check if ignorable errors file exists."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (findfile(value(dir_ignored_errors->dir_ignorable_errfile)) > 0)
    SET dm_err->eproc = "Load ignorable errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    DEFINE rtl2 value(dir_ignored_errors->dir_ignorable_errfile)
    SELECT INTO "nl:"
     FROM rtl2t t
     WHERE t.line > " "
     HEAD REPORT
      dir_ignored_errors->cnt = 0
     DETAIL
      dir_ignored_errors->cnt = (dir_ignored_errors->cnt+ 1)
      IF (mod(dir_ignored_errors->cnt,10)=1)
       stat = alterlist(dir_ignored_errors->qual,(dir_ignored_errors->cnt+ 9))
      ENDIF
      dir_ignored_errors->qual[dir_ignored_errors->cnt].error = trim(t.line)
     FOOT REPORT
      stat = alterlist(dir_ignored_errors->qual,dir_ignored_errors->cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_ignored_errors)
   ENDIF
   IF (dclfe_force_load_ind=1)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("Resetting error structure due to force load ind",dm_err->logfile,0)
    ENDIF
    FOR (dclfe_err_cnt = 1 TO size(dir_errors_encountered->qual,5))
      SET stat = alterlist(dir_errors_encountered->qual[dclfe_err_cnt].qual,0)
    ENDFOR
    SET stat = alterlist(dir_errors_encountered->qual,0)
    SET dclfe_err_cnt = 0
    SET dir_errors_encountered->cmd_cnt = 0
   ENDIF
   SET dm_err->eproc = "Check Operation Logfile for Errors."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   FREE DEFINE rtl2
   SET logical dclfe_operlogfile_logical dclfe_oper_logfile
   DEFINE rtl2 "dclfe_operlogfile_logical"
   SELECT INTO "nl:"
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
     dclfe_end = 0, dclfe_err_str = ""
     IF (findstring("ORA-",t.line,0) > 0)
      dclfe_err_type = "ORA-"
     ELSEIF (findstring("EXP-",t.line,0) > 0)
      dclfe_err_type = "EXP-"
     ELSEIF (findstring("IMP-",t.line,0) > 0)
      dclfe_err_type = "IMP-"
     ELSEIF (findstring("LOG FILE NOT FOUND",t.line,0) > 0)
      dclfe_err_type = "OTHER"
     ENDIF
     IF (dclfe_err_type > "")
      IF (dclfe_err_type="OTHER")
       dclfe_err_str = "", dclfe_end = 1
      ELSE
       dclfe_start = findstring(dclfe_err_type,t.line,0), dclfe_end = findstring(" ",t.line,
        dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start) - 1),t.line)
      ENDIF
      dclfe_ndx = 0
      IF (locateval(dclfe_ndx,1,dir_ignored_errors->cnt,dclfe_err_str,dir_ignored_errors->qual[
       dclfe_ndx].error)=0)
       IF (dclfe_add_cmd=1)
        dclfe_err_ind = 1, dir_errors_encountered->cmd_cnt = (dir_errors_encountered->cmd_cnt+ 1),
        stat = alterlist(dir_errors_encountered->qual,dir_errors_encountered->cmd_cnt),
        dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].logfile_name =
        dclfe_oper_logfile, dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].dee_op_id
         = dclfe_op_id, dclfe_add_cmd = 0
       ENDIF
       dclfe_ndx = 0
       IF (locateval(dclfe_ndx,1,dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].
        error_cnt,dclfe_err_str,dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[
        dclfe_ndx].error)=0)
        dclfe_err_cnt = (dclfe_err_cnt+ 1), dir_errors_encountered->qual[dir_errors_encountered->
        cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(dir_errors_encountered->qual[
         dir_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
        dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
        dclfe_err_str, dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[
        dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(t.line)) - dclfe_end),t.line)
       ELSE
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
        ENDIF
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("Ignored error:",dir_ignored_errors->qual[dclfe_ndx].error," from file:",
         dclfe_oper_logfile))
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_errors_encountered)
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_mixed_table_data(dlmtd_force_load_ind)
   DECLARE dlmtd_start = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_end = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_qual_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get mixed tables"
   IF ((dir_mixed_tables_data->cnt > 0)
    AND dlmtd_force_load_ind=0)
    RETURN(1)
   ENDIF
   SET dir_mixed_tables_data->cnt = 0
   SET stat = alterlist(dir_mixed_tables_data->tbl,0)
   SELECT INTO "nl:"
    FROM dm_info di,
     dm2_user_tables dut,
     dm_tables_doc dtd
    PLAN (di
     WHERE di.info_domain="DM2_MIXED_TABLE-*")
     JOIN (dut
     WHERE di.info_name=dut.table_name)
     JOIN (dtd
     WHERE dut.table_name=dtd.table_name)
    ORDER BY di.info_name
    HEAD di.info_name
     dir_mixed_tables_data->cnt = (dir_mixed_tables_data->cnt+ 1)
     IF (mod(dir_mixed_tables_data->cnt,10)=1)
      stat = alterlist(dir_mixed_tables_data->tbl,(dir_mixed_tables_data->cnt+ 9))
     ENDIF
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].table_name = di.info_name,
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].table_suffix = dtd.table_suffix,
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].prefix = cnvtlower(build(
       dir_clin_copy_data->ind_mixed_parfile_prefix,dtd.table_suffix)),
     dlmtd_qual_cnt = 0
    DETAIL
     dlmtd_qual_cnt = (dlmtd_qual_cnt+ 1)
     IF (mod(dlmtd_qual_cnt,10)=1)
      stat = alterlist(dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual,(dlmtd_qual_cnt+ 9
       ))
     ENDIF
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].where_clause = di
     .info_char, dlmtd_start = 0, dlmtd_end = 0,
     dlmtd_start = (findstring("-",trim(di.info_domain),0)+ 1), dlmtd_end = findstring("-",trim(di
       .info_domain),dlmtd_start,1), dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[
     dlmtd_qual_cnt].process_type = substring(dlmtd_start,(dlmtd_end - dlmtd_start),di.info_domain),
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].data_type =
     substring((dlmtd_end+ 1),(size(trim(di.info_domain)) - dlmtd_start),trim(di.info_domain))
    FOOT  di.info_name
     stat = alterlist(dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual,dlmtd_qual_cnt),
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].where_clause_cnt = dlmtd_qual_cnt
    FOOT REPORT
     stat = alterlist(dir_mixed_tables_data->tbl,dir_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Mixed Tables Exist in DM_INFO."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_mixed_tables_data)
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
    FROM dm2_user_tables t
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
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE') ")
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
        SET dcsa_error_msg = concat("Application Id ",trim(dcsa_fmt_appl_id))
        SET dcsa_error_msg = concat(dcsa_error_msg," is no longer active.")
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN ("RUNNING", null)
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
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF (cursys != "AXP")
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
 SET trace = nowarning
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
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
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
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(retrieve_data->result_status,- (1)) < 0)
  FREE RECORD retrieve_data
  RECORD retrieve_data(
    1 result_str = vc
    1 result_status = i2
  )
  SET retrieve_data->result_status = 0
  SET retrieve_data->result_str = " "
 ENDIF
 IF (validate(db2_node_info->node_fnd,- (1)) < 0)
  FREE RECORD db2_node_info
  RECORD db2_node_info(
    1 node_fnd = i2
    1 node_name = vc
    1 protocol_fnd = i2
    1 protocol = vc
    1 hostname_fnd = i2
    1 hostname = vc
    1 service_name_fnd = i2
    1 service_name = vc
  )
  SET db2_node_info->node_fnd = 0
  SET db2_node_info->protocol_fnd = 0
  SET db2_node_info->hostname_fnd = 0
  SET db2_node_info->service_name_fnd = 0
  SET db2_node_info->node_name = " "
  SET db2_node_info->protocol = "-"
  SET db2_node_info->hostname = "-"
  SET db2_node_info->service_name = "-"
 ENDIF
 IF (validate(db2_dbase_info->dbase_fnd,- (1)) < 0)
  FREE RECORD db2_dbase_info
  RECORD db2_dbase_info(
    1 dbase_fnd = i2
    1 alias = vc
    1 dbase_name_fnd = i2
    1 dbase_name = vc
    1 node_name_fnd = i2
    1 node_name = vc
    1 dir_entry_ty_fnd = i2
    1 dir_entry_ty = vc
    1 authen_fnd = i2
    1 authen = vc
    1 ctlg_nd_nbr_fnd = i2
    1 ctlg_nd_nbr = vc
  )
  SET db2_dbase_info->dbase_fnd = 0
  SET db2_dbase_info->dbase_name_fnd = 0
  SET db2_dbase_info->node_name_fnd = 0
  SET db2_dbase_info->dir_entry_ty_fnd = 0
  SET db2_dbase_info->authen_fnd = 0
  SET db2_dbase_info->ctlg_nd_nbr_fnd = 0
  SET db2_dbase_info->alias = " "
  SET db2_dbase_info->dbase_name = "-"
  SET db2_dbase_info->node_name = "-"
  SET db2_dbase_info->dir_entry_ty = "-"
  SET db2_dbase_info->authen = "-"
  SET db2_dbase_info->ctlg_nd_nbr = "-"
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
 IF (validate(db2_table->full_table_name,- (1)) < 0)
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
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE validate_node_info(sbr_nname=vc,sbr_ni_ignore_err=i2) = i2
 DECLARE validate_dbase_info(sbr_vi_dbase=vc,sbr_vi_ignore_err=i2) = i2
 DECLARE retrieve_data(sbr_srch_str=vc,sbr_sprtr=vc,sbr_rd_str=vc) = i2
 DECLARE db2_push_dcl_w_connect(sbr_dwc_dbase=vc,sbr_dwc_user=vc,sbr_dwc_user_pwd=vc,sbr_dwc_str=vc,
  sbr_dwc_commit_ind=i2) = i2
 DECLARE dm2parse_output(sbr_attr_nbr=i4,sbr_parse_fname=vc,sbr_orientation=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_system_defs_init(sbr_sdi_regen_ind=i2) = i2
 DECLARE dm2_get_srvname(sbr_spc_view=i2) = i2
 DECLARE dm2_fill_nick_except(sbr_alias=vc) = vc
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_validate_dblink(vdl_linkname=vc) = i2
 DECLARE dm2_include_exclude_list() = vc
 DECLARE dm2_set_nn_default(dsn_datatype=vc) = vc
 DECLARE dm2_findfile(sbr_file_path=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_toolset_usage(null) = i2
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
 SUBROUTINE validate_node_info(sbr_nname,sbr_ni_ignore_err)
   DECLARE vni_return = i2 WITH protect, noconstant(1)
   DECLARE err_pos = i4 WITH protect, noconstant(0)
   SET db2_node_info->node_fnd = 0
   SET db2_node_info->protocol_fnd = 0
   SET db2_node_info->hostname_fnd = 0
   SET db2_node_info->service_name_fnd = 0
   SET db2_node_info->node_name = " "
   SET db2_node_info->protocol = "-"
   SET db2_node_info->hostname = "-"
   SET db2_node_info->service_name = "-"
   IF (dm2_push_dcl("db2 list node directory")=0)
    IF (sbr_ni_ignore_err=1)
     IF (findstring("SQL1027N",dm_err->errtext)=0
      AND findstring("SQL1037W",dm_err->errtext)=0)
      RETURN(0)
     ELSE
      SET dm_err->eproc =
      "Message reported when executing db2 list node is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ELSE
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
    DETAIL
     IF (vni_return=1)
      IF ((db2_node_info->node_fnd=0))
       IF ((db2_node_info->node_name=" "))
        IF (retrieve_data("Node name","=",r.line)=0)
         vni_return = 0
        ELSEIF ((retrieve_data->result_status=1))
         IF (cnvtupper(retrieve_data->result_str)=cnvtupper(sbr_nname))
          db2_node_info->node_name = cnvtupper(sbr_nname), db2_node_info->node_fnd = 1
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (retrieve_data("Node name","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->node_fnd = 0
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Protocol","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->protocol = retrieve_data->result_str, db2_node_info->protocol_fnd = 1
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Hostname","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->hostname = retrieve_data->result_str, db2_node_info->hostname_fnd = 1
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Service name","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->service_name = retrieve_data->result_str, db2_node_info->service_name_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (vni_return=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ELSEIF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET vni_return = 0
   ENDIF
   RETURN(vni_return)
 END ;Subroutine
 SUBROUTINE validate_dbase_info(sbr_vi_dbase,sbr_vi_ignore_err)
   DECLARE vdi_return = i2 WITH protect, noconstant(1)
   SET db2_dbase_info->dbase_fnd = 0
   SET db2_dbase_info->dbase_name_fnd = 0
   SET db2_dbase_info->node_name_fnd = 0
   SET db2_dbase_info->dir_entry_ty_fnd = 0
   SET db2_dbase_info->authen_fnd = 0
   SET db2_dbase_info->ctlg_nd_nbr_fnd = 0
   SET db2_dbase_info->alias = " "
   SET db2_dbase_info->dbase_name = "-"
   SET db2_dbase_info->node_name = "-"
   SET db2_dbase_info->dir_entry_ty = "-"
   SET db2_dbase_info->authen = "-"
   SET db2_dbase_info->ctlg_nd_nbr = "-"
   IF (dm2_push_dcl("db2 list database directory")=0)
    IF (sbr_vi_ignore_err=1)
     IF (findstring("SQL1031N",dm_err->errtext)=0
      AND findstring("SQL1057W",dm_err->errtext)=0)
      RETURN(0)
     ELSE
      SET dm_err->eproc =
      "Message reported when executing db2 list database is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ELSE
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
    DETAIL
     IF (vdi_return=1)
      IF ((db2_dbase_info->dbase_fnd=0))
       IF ((db2_dbase_info->alias=" "))
        IF (retrieve_data("Database alias","=",r.line)=0)
         vdi_return = 0
        ELSEIF ((retrieve_data->result_status=1))
         IF (cnvtupper(retrieve_data->result_str)=cnvtupper(sbr_vi_dbase))
          db2_dbase_info->alias = cnvtupper(sbr_vi_dbase), db2_dbase_info->dbase_fnd = 1
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (retrieve_data("Database alias","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dbase_fnd = 0
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Database name","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dbase_name = retrieve_data->result_str, db2_dbase_info->dbase_name_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Node name","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->node_name = retrieve_data->result_str, db2_dbase_info->node_name_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Directory entry type","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dir_entry_ty = retrieve_data->result_str, db2_dbase_info->dir_entry_ty_fnd =
        1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Authentication","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->authen = retrieve_data->result_str, db2_dbase_info->authen_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Catalog database partition number","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->ctlg_nd_nbr = retrieve_data->result_str, db2_dbase_info->ctlg_nd_nbr_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (vdi_return=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ELSEIF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Reading through Database List Directory"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET vdi_return = 0
   ENDIF
   RETURN(vdi_return)
 END ;Subroutine
 SUBROUTINE retrieve_data(sbr_srch_str,sbr_sprtr,sbr_rd_str)
   SET retrieve_data->result_str = " "
   SET retrieve_data->result_status = 0
   DECLARE str_loc = i4 WITH protect, noconstant(0)
   DECLARE str_len = i4 WITH protect, noconstant(0)
   DECLARE srch_str_len = i4 WITH protect, noconstant(0)
   DECLARE sstart = i4 WITH protect, noconstant(0)
   DECLARE slength = i4 WITH protect, noconstant(0)
   IF ( NOT (sbr_sprtr IN (" ", "=")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Separator parameter invalid.  Must be either ' ' or '='."
    SET dm_err->eproc = "Separator validation."
    RETURN(0)
   ENDIF
   SET str_loc = findstring(sbr_srch_str,sbr_rd_str)
   IF (str_loc > 0)
    IF (sbr_sprtr="=")
     SET str_len = textlen(trim(sbr_rd_str))
     SET str_loc = findstring(sbr_sprtr,sbr_rd_str)
     IF (str_loc=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Separator not found.  DB2 List output contains invalid/outdated info."
      SET dm_err->eproc = concat("Locating '",sbr_sprtr,"' on line containing '",sbr_srch_str,"'.")
      RETURN(0)
     ELSE
      SET sstart = (str_loc+ 1)
      SET slength = (str_len - str_loc)
      SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
      SET retrieve_data->result_status = 1
      RETURN(1)
     ENDIF
    ELSE
     SET str_len = textlen(trim(sbr_rd_str))
     SET srch_str_len = textlen(sbr_srch_str)
     SET sstart = (str_loc+ srch_str_len)
     SET slength = (((str_len - str_loc) - srch_str_len)+ 1)
     SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
     SET retrieve_data->result_status = 1
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE db2_push_dcl_w_connect(sbr_dwc_dbase,sbr_dwc_user,sbr_dwc_user_pwd,sbr_dwc_str,
  sbr_dwc_commit_ind)
   DECLARE push_rtrn = i2 WITH protect, noconstant(1)
   IF (dm2_push_dcl(concat('db2 "connect to ',cnvtlower(sbr_dwc_dbase)," user ",cnvtlower(
      sbr_dwc_user)," using ",
     cnvtlower(sbr_dwc_user_pwd),'"'))=0)
    RETURN(0)
   ENDIF
   IF (sbr_dwc_commit_ind=1)
    IF (dm2_push_dcl(concat("db2 -c ",sbr_dwc_str))=0)
     SET push_rtrn = 0
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("db2 +c ",sbr_dwc_str))=0)
     SET push_rtrn = 0
    ENDIF
   ENDIF
   IF (dm2_push_dcl("db2 terminate")=0)
    SET push_rtrn = 0
   ENDIF
   RETURN(push_rtrn)
 END ;Subroutine
 SUBROUTINE dm2parse_output(sbr_nbr_attr,sbr_parse_fname,sbr_orientation)
   DECLARE select_str = vc WITH protect, noconstant(" ")
   DECLARE foot_str = vc WITH protect, noconstant(" ")
   DECLARE buf_cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE dm2_stat = i4 WITH protect, noconstant(0)
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   RECORD dm2parse_buf(
     1 qual[*]
       2 str = vc
   )
   SET select_str = concat('select into "nl:" r.line'," from rtlt r",' where r.line > " "'," detail "
    )
   FOR (attr_nbr = 1 TO sbr_nbr_attr)
     SET buf_cnt = (buf_cnt+ 1)
     IF (mod(buf_cnt,10)=1)
      SET stat = alterlist(dm2parse_buf->qual,(buf_cnt+ 9))
     ENDIF
     IF (attr_nbr=1)
      SET dm2parse_buf->qual[buf_cnt].str = concat(" if (findstring(dm2parse->attr1, r.line))",
       " cnt = cnt + 1"," if(mod(cnt,10) = 1)"," stat = alterlist(dm2parse->qual, cnt +9)"," endif",
       " if(retrieve_data(dm2parse->attr1, dm2parse->attr1sep, r.line))",
       " dm2parse->qual[cnt]->attr1val = retrieve_data->result_str"," endif")
     ELSE
      IF (sbr_orientation="V")
       SET dm2parse_buf->qual[buf_cnt].str = concat(" elseif (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ELSE
       SET dm2parse_buf->qual[buf_cnt].str = concat(" endif if (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ENDIF
     ENDIF
     IF (attr_nbr=sbr_nbr_attr)
      SET dm2parse_buf->qual[buf_cnt].str = concat(dm2parse_buf->qual[buf_cnt].str," endif")
     ENDIF
   ENDFOR
   SET stat = alterlist(dm2parse_buf->qual,buf_cnt)
   SET foot_str = concat(" foot report"," stat = alterlist(dm2parse->qual, cnt)"," with nocounter go"
    )
   SET dm2_stat = dm2_push_cmd("free define rtl go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd("free set file_loc go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_str = concat('set logical = file_loc "',sbr_parse_fname,'" go')
   SET dm2_stat = dm2_push_cmd(dm2_str,1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd('define rtl is "file_loc" go',1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(select_str,0))
    FOR (parse_cnt = 1 TO size(dm2parse_buf->qual,5))
     SET dm2_stat = dm2_push_cmd(dm2parse_buf->qual[parse_cnt].str,0)
     IF ( NOT (dm2_stat))
      RETURN(0)
     ENDIF
    ENDFOR
    IF (dm2_push_cmd(foot_str,1))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
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
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*")
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*")
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
 SUBROUTINE dm2_system_defs_init(sbr_sdi_regen_ind)
   DECLARE sdi_def_cur_user = vc WITH protect, constant(cnvtupper(currdbuser))
   DECLARE sdi_def1_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def3_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue3_exists_ind = i2 WITH protect, noconstant(0)
   CASE (currdb)
    OF "ORACLE":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("USER_VIEWS", "DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
      DETAIL
       CASE (d.table_name)
        OF "USER_VIEWS":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
        OF "DM2_DBA_TAB_COLS":
         sdi_def3_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error(
      "Verifying that table definitions exist for USER_VIEWS, DM2_DBA_TAB_COLUMNS, and DM2_DBA_TAB_COLS."
      )=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE user_views
       IF (check_error("Dropping USER_VIEWS definition.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD user_views FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD user_views FROM DATABASE v500
 TABLE user_views
  1 view_name  = c30 CCL(view_name)
  1 text_length  = f8 CCL(text_length)
  1 text  = vc32000 CCL(text)
  1 type_text_length  = f8 CCL(type_text_length)
  1 type_text  = vc4000 CCL(type_text)
  1 oid_text_length  = f8 CCL(oid_text_length)
  1 oid_text  = vc4000 CCL(oid_text)
  1 view_type_owner  = c30 CCL(view_type_owner)
  1 view_type  = c30 CCL(view_type)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE user_views
      IF (check_error("Generating USER_VIEWS CCL definition.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM user_views uv
      WHERE uv.view_name IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
      DETAIL
       CASE (uv.view_name)
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_vue2_exists_ind = 1
        OF "DM2_DBA_TAB_COLS":
         sdi_vue3_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error(
      "Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_vue2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_vue2_exists_ind=1)
       RDB drop view dm2_dba_tab_columns
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      CALL parser(concat("rdb grant select any table to ",sdi_def_cur_user," go"))
      RDB asis ( "create view dm2_dba_tab_columns (" ) asis (
      "  OWNER,            TABLE_NAME,        COLUMN_NAME,      DATA_TYPE," ) asis (
      "  DATA_LENGTH,      DATA_PRECISION,    DATA_SCALE,       NULLABLE," ) asis (
      "  COLUMN_ID,        DEFAULT_LENGTH,    DATA_DEFAULT,     NUM_DISTINCT," ) asis (
      "  LOW_VALUE,        HIGH_VALUE,        DENSITY,          NUM_NULLS," ) asis (
      "  NUM_BUCKETS,      LAST_ANALYZED,     SAMPLE_SIZE,      LOGGED," ) asis (
      "  COMPACT,          IDENTITY_IND,      GENERATED" ) asis ( ") as select" ) asis (
      "  c.owner,          c.table_name,      c.column_name,    c.data_type," ) asis (
      "  c.data_length,    c.data_precision,  c.data_scale,     c.nullable," ) asis (
      "  c.column_id,      c.default_length,  c.data_default,   c.num_distinct," ) asis (
      "  c.low_value,      c.high_value,      c.density,        c.num_nulls," ) asis (
      "  c.num_buckets,    c.last_analyzed,   c.sample_size,    'N/A'," ) asis (
      "  'N/A',            'N/A',             'N/A'" ) asis ( "from dba_tab_columns c" ) asis (
      "union all" ) asis ( "select" ) asis (
      "  dc.owner,         ds.synonym_name,   dc.column_name,   dc.data_type," ) asis (
      "  dc.data_length,   dc.data_precision, dc.data_scale,    dc.nullable," ) asis (
      "  dc.column_id,     dc.default_length, dc.data_default,  dc.num_distinct," ) asis (
      "  dc.low_value,     dc.high_value,     dc.density,       dc.num_nulls," ) asis (
      "  dc.num_buckets,   dc.last_analyzed,  dc.sample_size,   'N/A'," ) asis (
      "  'N/A',            'N/A',             'N/A'" ) asis (
      "from dba_tab_columns dc, dba_synonyms ds" ) asis ( "where ds.table_name = dc.table_name" )
      asis ( "  and ds.synonym_name != ds.table_name" ) asis ( "  and not exists " ) asis (
      "     (select c.synonym_name, count(*) " ) asis ( "          from dba_synonyms c " ) asis (
      "          where c.synonym_name = ds.synonym_name " ) asis (
      "          group by c.synonym_name " ) asis ( "          having count(*) > 1) " )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def2_exists_ind=1)
       DROP TABLE dm2_dba_tab_columns
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_dba_tab_columns
      IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (((sdi_vue3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_vue3_exists_ind=1)
       RDB drop view dm2_dba_tab_cols
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      CALL parser(concat("rdb grant select any table to ",sdi_def_cur_user," go"))
      RDB asis ( "create view dm2_dba_tab_cols (" ) asis (
      "  OWNER,            TABLE_NAME,        COLUMN_NAME,      DATA_TYPE," ) asis (
      "  DATA_LENGTH,      DATA_PRECISION,    DATA_SCALE,       NULLABLE," ) asis (
      "  COLUMN_ID,        DEFAULT_LENGTH,    DATA_DEFAULT,     NUM_DISTINCT," ) asis (
      "  LOW_VALUE,        HIGH_VALUE,        DENSITY,          NUM_NULLS," ) asis (
      "  NUM_BUCKETS,      LAST_ANALYZED,     SAMPLE_SIZE,      LOGGED," ) asis (
      "  COMPACT,          IDENTITY_IND,      GENERATED" ) asis ( ") as select" ) asis (
      "  c.owner,          c.table_name,      c.column_name,    c.data_type," ) asis (
      "  c.data_length,    c.data_precision,  c.data_scale,     c.nullable," ) asis (
      "  c.column_id,      c.default_length,  c.data_default,   c.num_distinct," ) asis (
      "  c.low_value,      c.high_value,      c.density,        c.num_nulls," ) asis (
      "  c.num_buckets,    c.last_analyzed,   c.sample_size,    'N/A'," ) asis (
      "  'N/A',            'N/A',             'N/A'" ) asis ( "from dba_tab_columns c" )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (((sdi_def3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def3_exists_ind=1)
       DROP TABLE dm2_dba_tab_cols
       IF (check_error("Dropping DM2_DBA_TAB_COLS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_cols FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_cols FROM DATABASE v500
 TABLE dm2_dba_tab_cols
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_dba_tab_cols
      IF (check_error("Creating DM2_DBA_TAB_COLS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    OF "DB2UDB":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("TABLES", "DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
      DETAIL
       CASE (d.table_name)
        OF "TABLES":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
        OF "DM2_DBA_TAB_COLS":
         sdi_def3_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error(
      "Verifying that table definitions exist for TABLES, DM2_DBA_TAB_COLUMNS, and DM2_DBA_TAB_COLS."
      )=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE tables
       IF (check_error("Dropping TABLES definition.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD tables FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD tables FROM DATABASE v500
 TABLE tables
  1 tabschema  = vc128 CCL(tabschema)
  1 tabname  = vc128 CCL(tabname)
  1 definer  = vc128 CCL(definer)
  1 type  = c1 CCL(type)
  1 status  = c1 CCL(status)
  1 base_tabschema  = vc128 CCL(base_tabschema)
  1 base_tabname  = vc128 CCL(base_tabname)
  1 rowtypeschema  = vc128 CCL(rowtypeschema)
  1 rowtypename  = vc128 CCL(rowtypename)
  1 create_time  = dq8 CCL(create_time)
  1 stats_time  = dq8 CCL(stats_time)
  1 colcount  = f8 CCL(colcount)
  1 tableid  = f8 CCL(tableid)
  1 tbspaceid  = f8 CCL(tbspaceid)
  1 card  = f8 CCL(card)
  1 npages  = f8 CCL(npages)
  1 fpages  = f8 CCL(fpages)
  1 overflow  = f8 CCL(overflow)
  1 tbspace  = vc128 CCL(tbspace)
  1 index_tbspace  = vc128 CCL(index_tbspace)
  1 long_tbspace  = vc128 CCL(long_tbspace)
  1 parents  = f8 CCL(parents)
  1 children  = f8 CCL(children)
  1 selfrefs  = f8 CCL(selfrefs)
  1 keycolumns  = f8 CCL(keycolumns)
  1 keyindexid  = f8 CCL(keyindexid)
  1 keyunique  = f8 CCL(keyunique)
  1 checkcount  = f8 CCL(checkcount)
  1 datacapture  = c1 CCL(datacapture)
  1 const_checked  = c32 CCL(const_checked)
  1 pmap_id  = f8 CCL(pmap_id)
  1 partition_mode  = c1 CCL(partition_mode)
  1 log_attribute  = c1 CCL(log_attribute)
  1 pctfree  = f8 CCL(pctfree)
  1 append_mode  = c1 CCL(append_mode)
  1 refresh  = c1 CCL(refresh)
  1 refresh_time  = dq8 CCL(refresh_time)
  1 locksize  = c1 CCL(locksize)
  1 volatile  = c1 CCL(volatile)
  1 remarks  = vc254 CCL(remarks)
  1 row_format  = c1 CCL(row_format)
  1 property  = c32 CCL(property)
  1 statistics_profile  = vc32000 CCL(statistics_profile)
  1 compression  = c1 CCL(compression)
  1 access_mode  = c1 CCL(access_mode)
  1 clustered  = c1 CCL(clustered)
  1 active_blocks  = f8 CCL(active_blocks)
  1 droprule  = c1 CCL(droprule)
  1 maxfreespacesearch  = f8 CCL(maxfreespacesearch)
 END TABLE tables
      IF (check_error("Generating TABLES CCL definition.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM (syscat.tables t)
      WHERE t.tabname IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
       AND t.tabschema=sdi_def_cur_user
       AND t.type="V"
      DETAIL
       CASE (t.tabname)
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_vue2_exists_ind = 1
        OF "DM2_DBA_TAB_COLS":
         sdi_vue3_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error(
      "Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_vue2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_vue2_exists_ind=1)
       RDB drop view dm2_dba_tab_columns
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      RDB asis ( "create view dm2_dba_tab_columns (" ) asis (
      "  OWNER,                 TABLE_NAME,             COLUMN_NAME,     DATA_TYPE," ) asis (
      "  DATA_LENGTH,           DATA_PRECISION,         DATA_SCALE,      NULLABLE," ) asis (
      "  COLUMN_ID,             DEFAULT_LENGTH,         DATA_DEFAULT,    NUM_DISTINCT," ) asis (
      "  LOW_VALUE,             HIGH_VALUE,             DENSITY,         NUM_NULLS," ) asis (
      "  NUM_BUCKETS,           LAST_ANALYZED,          SAMPLE_SIZE,     LOGGED," ) asis (
      "  COMPACT,               IDENTITY_IND,           GENERATED" ) asis ( ") as select" ) asis (
      "  sc.tabschema,          sc.tabname,             sc.colname,      varchar(sc.typename,106)," )
       asis ( "  bigint(sc.length),     bigint(0),              sc.scale,        sc.nulls," ) asis (
      "  sc.colno,              bigint(length(sc.default))," ) asis ( "  CASE sc.identity" ) asis (
      "    when 'Y' THEN" ) asis ( "      CASE sc.generated" ) asis (
      "        when 'D' THEN 'GENERATED BY DEFAULT AS IDENTITY'" ) asis ( "        else sc.default" )
       asis ( "      END" ) asis ( "    else sc.default" ) asis ( "  END," ) asis ( "  sc.colcard," )
       asis ( "  sc.low2key,            sc.high2key,            sc.nmostfreq,    sc.numnulls," ) asis
       ( "  sc.nquantiles,         current timestamp,      bigint(0),       varchar(sc.logged,3)," )
      asis ( "  varchar(sc.compact,3), varchar(sc.identity,3), varchar(sc.generated,3)" ) asis (
      "from syscat.columns sc" )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ENDIF
     IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def2_exists_ind=1)
       DROP TABLE dm2_dba_tab_columns
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_columns
      IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (((sdi_vue3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_vue3_exists_ind=1)
       RDB drop view dm2_dba_tab_cols
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      RDB asis ( "create view dm2_dba_tab_cols (" ) asis (
      "  OWNER,                 TABLE_NAME,             COLUMN_NAME,     DATA_TYPE," ) asis (
      "  DATA_LENGTH,           DATA_PRECISION,         DATA_SCALE,      NULLABLE," ) asis (
      "  COLUMN_ID,             DEFAULT_LENGTH,         DATA_DEFAULT,    NUM_DISTINCT," ) asis (
      "  LOW_VALUE,             HIGH_VALUE,             DENSITY,         NUM_NULLS," ) asis (
      "  NUM_BUCKETS,           LAST_ANALYZED,          SAMPLE_SIZE,     LOGGED," ) asis (
      "  COMPACT,               IDENTITY_IND,           GENERATED" ) asis ( ") as select" ) asis (
      "  sc.tabschema,          sc.tabname,             sc.colname,      varchar(sc.typename,106)," )
       asis ( "  bigint(sc.length),     bigint(0),              sc.scale,        sc.nulls," ) asis (
      "  sc.colno,              bigint(length(sc.default))," ) asis ( "  CASE sc.identity" ) asis (
      "    when 'Y' THEN" ) asis ( "      CASE sc.generated" ) asis (
      "        when 'D' THEN 'GENERATED BY DEFAULT AS IDENTITY'" ) asis ( "        else sc.default" )
       asis ( "      END" ) asis ( "    else sc.default" ) asis ( "  END," ) asis ( "  sc.colcard," )
       asis ( "  sc.low2key,            sc.high2key,            sc.nmostfreq,    sc.numnulls," ) asis
       ( "  sc.nquantiles,         current timestamp,      bigint(0),       varchar(sc.logged,3)," )
      asis ( "  varchar(sc.compact,3), varchar(sc.identity,3), varchar(sc.generated,3)" ) asis (
      "from syscat.columns sc" )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ENDIF
     IF (((sdi_def3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def3_exists_ind=1)
       DROP TABLE dm2_dba_tab_cols
       IF (check_error("Dropping DM2_DBA_TAB_COLS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_cols FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_cols FROM DATABASE v500
 TABLE dm2_dba_tab_cols
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_cols
      IF (check_error("Creating DM2_DBA_TAB_COLS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    OF "SQLSRV":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("TABLES", "DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
      DETAIL
       CASE (d.table_name)
        OF "TABLES":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
        OF "DM2_DBA_TAB_COLS":
         sdi_def3_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error(
      "Verifying that table definitions exist for TABLES, DM2_DBA_TAB_COLUMNS, and DM2_DBA_TAB_COLS."
      )=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE tables
       IF (check_error("Dropping TABLES definition.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD tables FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD tables FROM DATABASE v500
 TABLE tables
  1 table_catalog  = vc128 CCL(table_catalog)
  1 table_schema  = vc128 CCL(table_schema)
  1 table_name  = vc128 CCL(table_name)
  1 table_type  = vc10 CCL(table_type)
 END TABLE tables
      IF (check_error("Generating TABLES CCL definition.")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (sbr_sdi_regen_ind IN (0, 1))
      SELECT INTO "nl:"
       FROM (information_schema.tables t)
       WHERE t.table_name IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
        AND t.table_schema=sdi_def_cur_user
        AND t.table_type="VIEW"
       DETAIL
        CASE (t.table_name)
         OF "DM2_DBA_TAB_COLUMNS":
          sdi_vue2_exists_ind = 1
         OF "DM2_DBA_TAB_COLS":
          sdi_vue3_exists_ind = 1
        ENDCASE
       WITH nocounter
      ;end select
      IF (check_error(
       "Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist.")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (((sdi_vue2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
       IF (sdi_vue2_exists_ind=1)
        RDB drop view dm2_dba_tab_columns
        END ;Rdb
        IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       RDB asis ( "create view DM2_DBA_TAB_COLUMNS as select " ) asis ( " c.TABLE_SCHEMA OWNER," )
       asis ( " c.TABLE_NAME TABLE_NAME," ) asis ( " c.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis (
        " convert(int,c.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c.TABLE_SCHEMA+'.'+c.TABLE_NAME),  " )
       asis ( "             c.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c.COLUMN_DEFAULT,2,(len(c.COLUMN_DEFAULT) - 2)) " )
       asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from INFORMATION_SCHEMA.COLUMNS c " ) asis
       ( "union all" ) asis ( "select" ) asis ( " c2.TABLE_SCHEMA OWNER," ) asis (
       " c2.TABLE_NAME TABLE_NAME," ) asis ( " c2.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c2.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c2.CHARACTER_MAXIMUM_LENGTH, c2.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis
        ( " convert(int,c2.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c2.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c2.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c2.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c2.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c2.TABLE_SCHEMA+'.'+c2.TABLE_NAME),  " )
        asis ( "             c2.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c2.COLUMN_DEFAULT,2,(len(c2.COLUMN_DEFAULT) - 2)) " )
        asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from master.INFORMATION_SCHEMA.COLUMNS c2 "
        ) asis ( "where c2.TABLE_SCHEMA = 'INFORMATION_SCHEMA'" )
       END ;Rdb
       IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
       IF (sdi_def2_exists_ind=1)
        DROP TABLE dm2_dba_tab_columns
        IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
       CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_columns
       IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      IF (((sdi_vue3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
       IF (sdi_vue3_exists_ind=1)
        RDB drop view dm2_dba_tab_cols
        END ;Rdb
        IF (check_error("Dropping DM2_DBA_TAB_COLS view.")=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       RDB asis ( "create view DM2_DBA_TAB_COLS as select " ) asis ( " c.TABLE_SCHEMA OWNER," ) asis
       ( " c.TABLE_NAME TABLE_NAME," ) asis ( " c.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis (
        " convert(int,c.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c.TABLE_SCHEMA+'.'+c.TABLE_NAME),  " )
       asis ( "             c.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c.COLUMN_DEFAULT,2,(len(c.COLUMN_DEFAULT) - 2)) " )
       asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from INFORMATION_SCHEMA.COLUMNS c " ) asis
       ( "union all" ) asis ( "select" ) asis ( " c2.TABLE_SCHEMA OWNER," ) asis (
       " c2.TABLE_NAME TABLE_NAME," ) asis ( " c2.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c2.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c2.CHARACTER_MAXIMUM_LENGTH, c2.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis
        ( " convert(int,c2.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c2.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c2.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c2.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c2.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c2.TABLE_SCHEMA+'.'+c2.TABLE_NAME),  " )
        asis ( "             c2.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c2.COLUMN_DEFAULT,2,(len(c2.COLUMN_DEFAULT) - 2)) " )
        asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from master.INFORMATION_SCHEMA.COLUMNS c2 "
        ) asis ( "where c2.TABLE_SCHEMA = 'INFORMATION_SCHEMA'" )
       END ;Rdb
       IF (check_error("CREATING DM2_DBA_TAB_COLS VIEW")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      IF (((sdi_def3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
       IF (sdi_def3_exists_ind=1)
        DROP TABLE dm2_dba_tab_cols
        IF (check_error("Dropping DM2_DBA_TAB_COLS table def.")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       DROP DDLRECORD dm2_dba_tab_cols FROM DATABASE v500 WITH deps_deleted
       CREATE DDLRECORD dm2_dba_tab_cols FROM DATABASE v500
 TABLE dm2_dba_tab_cols
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_cols
       IF (check_error("Creating DM2_DBA_TAB_COLS table def.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDCASE
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_srvname(sbr_spc_view)
   IF ( NOT (sbr_spc_view IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid view indicator"
    SET dm_err->eproc = "Retrieving server name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (sbr_spc_view=0)
     SELECT INTO "nl:"
      FROM sysservers s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM dm2syssrv s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Retreiving server name in subroutine DM2_GET_SRVNAME")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No row qualified"
     SET dm_err->eproc = "Retreiving server name in subroutine DM2_GET_SRVNAME"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_nick_except(sbr_alias)
   DECLARE dfne_in_clause = vc WITH public, noconstant("")
   SET dfne_in_clause = concat("substring(1,3,",sbr_alias,".table_name) != 'DM2' ")
   SET dfne_in_clause = concat(dfne_in_clause," and ",sbr_alias,".table_name not in ('DM_INFO',",
    "'DM_SEGMENTS',",
    "'DM_TABLE_LIST',","'DM_USER_CONSTRAINTS',","'DM_USER_CONS_COLUMNS',","'DM_USER_IND_COLUMNS',",
    "'DM_USER_TAB_COLS',",
    "'EXPLAIN_ARGUMENT',","'EXPLAIN_INSTANCE',","'EXPLAIN_OBJECT',","'EXPLAIN_OPERATOR',",
    "'EXPLAIN_PREDICATE',",
    "'EXPLAIN_STATEMENT',","'EXPLAIN_STREAM') ")
   RETURN(dfne_in_clause)
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
   IF (findstring("-",sbr_file_prefix) IN (0, 1))
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
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option=
   "INHOUSE"))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
       dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
    SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
     sbr_vfp_dir)
    SET dm_err->eproc = "File Prefix Validation"
    SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_validate_dblink(vdl_linkname)
   DECLARE vdl_dot_pos = i4 WITH protect, noconstant(0)
   DECLARE vdl_match_cnt = i4 WITH protect, noconstant(0)
   SET vdl_linkname = trim(vdl_linkname,3)
   IF (findstring(".",vdl_linkname,1) > 0)
    SET dm_err->emsg = concat("dm2_common_routines,dm2_validate_dblink:  ","The database link name (",
     vdl_linkname,") is invalid.  Millenium / CCL ",
     "does not support dots (.) in database link names for SQL purposes.")
    SET dm_err->user_action = concat(
     "Specify the base part of the link name only in the command.    ",
     "Example1: Specify ADMIN instead of ADMIN.WORLD or ADMIN.WORLD.COM    ",
     "Example2: Select * from table_name@ADMIN vs select * from table_name@ADMIN.WORLD    ",
     "Example3: Oragen3 'table_name@ADMIN' vs Oragen3 'table_name@ADMIN.WORLD")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM all_db_links adl
    DETAIL
     vdl_dot_pos = findstring(".",adl.db_link,1)
     IF (vdl_dot_pos=0)
      IF (cnvtupper(vdl_linkname)=cnvtupper(adl.db_link))
       dm2_install_schema->adl_username = adl.username, vdl_match_cnt = (vdl_match_cnt+ 1)
      ENDIF
     ELSE
      IF (cnvtupper(vdl_linkname)=cnvtupper(substring(1,(vdl_dot_pos - 1),adl.db_link)))
       dm2_install_schema->adl_username = adl.username, vdl_match_cnt = (vdl_match_cnt+ 1)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET dm_err->eproc = "Selecting against all_db_links to validate database link name."
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (vdl_match_cnt != 1)
    IF (vdl_match_cnt=0)
     SET dm_err->emsg = concat("dm2_common_routines,dm2_validate_dblink:  The database link name (",
      vdl_linkname,") was not found to be a valid database link name in ALL_DB_LINKS. ")
    ELSEIF (vdl_match_cnt > 1)
     SET dm_err->emsg = concat(
      "dm2_common_routines,dm2_validate_dblink:  Multiple occurences of the database ","link name (",
      vdl_linkname,") was found in ALL_DB_LINKS.  To prevent Millenium ",
      "processing errors, the first part of the database link name (text before the first ",
      "'.') needs to be unique.")
    ENDIF
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_include_exclude_list(null)
   DECLARE diel_where_clause = vc WITH public, noconstant("")
   SET dm_err->eproc = "Creating list of data_model_section values to include/exclude"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INCL_EXCL"
    ORDER BY d.info_char
    HEAD REPORT
     diel_where_clause = " "
    HEAD d.info_char
     cnt = 0
     IF (diel_where_clause=" ")
      IF (cnvtupper(d.info_char)="INCLUDE")
       diel_where_clause = "td.data_model_section in "
      ELSEIF (cnvtupper(d.info_char)="EXCLUDE")
       diel_where_clause = "td.data_model_section not in "
      ELSE
       diel_where_clause = "ERROR - invalid type"
      ENDIF
     ELSE
      diel_where_clause = "ERROR - can only process one type (include/exclude)"
     ENDIF
    DETAIL
     IF (substring(1,5,diel_where_clause) != "ERROR")
      cnt = (cnt+ 1)
      IF (cnt > 1)
       diel_where_clause = concat(diel_where_clause,"','",trim(d.info_name,3))
      ELSE
       diel_where_clause = concat(diel_where_clause," ('",trim(d.info_name,3))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (substring(1,5,diel_where_clause) != "ERROR")
      diel_where_clause = concat(diel_where_clause,"')")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ELSEIF (curqual=0)
    SET diel_where_clause = "NONE"
   ELSEIF (substring(1,5,diel_where_clause)="ERROR")
    SET dm_err->emsg = diel_where_clause
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ENDIF
   RETURN(diel_where_clause)
 END ;Subroutine
 SUBROUTINE dm2_set_nn_default(dsn_datatype)
   IF (currdb="ORACLE")
    DECLARE dsn_default = vc
    IF (dsn_datatype IN ("NUMBER", "FLOAT"))
     SET dsn_default = "0"
    ELSEIF (dsn_datatype="DATE")
     SET dsn_default = "TO_DATE('01/01/1900 00:00:00', 'MM/DD/YYYY HH24:MI:SS')"
    ELSEIF (dsn_datatype="*CHAR*")
     SET dsn_default = "' '"
    ELSE
     SET dsn_default = "ERROR"
    ENDIF
    RETURN(dsn_default)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_findfile(sbr_file_path)
   DECLARE dff_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str = vc WITH protect, noconstant(" ")
   DECLARE dff_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET dff_cmd_txt = concat("ls -l ",sbr_file_path)
    SET dff_err_str = concat(sbr_file_path," does not exist")
   ENDIF
   IF (cursys="AXP")
    CALL dm2_push_dcl(concat('@cer_install:dm2_findfile_os.com "',sbr_file_path,'"'))
   ELSE
    CALL dm2_push_dcl(dff_cmd_txt)
   ENDIF
   IF ((dm_err->err_ind=1))
    SET dm_err->err_ind = 0
    SET dff_tmp_err_ind = 1
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (cursys="AIX")
    IF (findstring(dff_err_str,dm_err->errtext,1,0) > 0)
     CALL echo("This is an acceptable error.")
     SET dm_err->emsg = concat("File",sbr_file_path," not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     RETURN(0)
    ELSEIF (dff_tmp_err_ind=1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSEIF (cursys="AXP")
    IF ((dm_err->errtext="NOT FOUND"))
     SET dm_err->emsg = concat("File",sbr_file_path," not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF ((dm_err->errtext="FOUND"))
     RETURN(1)
    ELSEIF (((dff_tmp_err_ind=1) OR ( NOT ((dm_err->errtext IN ("FOUND", "NOT FOUND"))))) )
     SET dm_err->emsg = dm_err->errtext
     SET dm_err->eproc = "Error in DM2_FINDFILE"
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
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
     ", de.target_operating_system = cursys ",", de.updt_applctx = 0 ",
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
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   DECLARE dtu_envid = i4
   DECLARE dtu_dm_info_exists = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dtu_envid = 0
   SET dtu_dm_info_exists = 0
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because database is DB2/SQLSRV")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="DM_INFO"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dtu_dm_info_exists = 1
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
   IF (currev < 8)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM toolset because the current rev is less then 8.0")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   IF (currdbuser="CDBA")
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because ADMIN database (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if process running in an in-house domain."
   SET inhouse_misc->inhouse_domain = 0
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET inhouse_misc->inhouse_domain = 1
   ENDIF
   IF ((inhouse_misc->inhouse_domain=0)
    AND dtu_dm_info_exists=1)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual=1)
     SET inhouse_misc->inhouse_domain = 1
    ENDIF
   ENDIF
   IF ((inhouse_misc->inhouse_domain=1))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because INHOUSE domain (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   IF (dtu_dm_info_exists=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "Using DM toolset because DM_INFO does not exist and DM2 toolset requires it's existence")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   SET dm_err->eproc = "Getting environment id."
   SELECT INTO "nl:"
    FROM dm_info a,
     dm_environment b
    WHERE a.info_domain="DATA MANAGEMENT"
     AND a.info_name="DM_ENV_ID"
     AND a.info_number=b.environment_id
    DETAIL
     dtu_envid = b.environment_id
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtain ENVIRONMENT_ID from DM_INFO."
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking if packages are installed"
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe,
     dm_ocd_log dol
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr IN (11277, 13384, 10292)
     AND dafe.environment_id=dol.environment_id
     AND dafe.alpha_feature_nbr=dol.ocd
     AND dol.project_type="INSTALL LOG"
     AND dol.project_name="POST-INST READMES"
     AND dol.status="COMPLETE"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr=10292
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_alpha_features_env dafe2
     WHERE dafe.environment_id=dafe2.environment_id
      AND dafe2.alpha_feature_nbr IN (11277, 13384))))
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if CODE_VALUE exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="CODE_VALUE"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Selecting from CODE_VALUE for codeset"
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=289570
      AND c.display="2004.02"
      AND c.active_ind=1
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual > 0)
     IF ((dm_err->debug_flag > 0))
      CALL echo("Using DM2 toolset because required code value exists.")
     ENDIF
     RETURN(dtu_use_dm2_toolset)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Using DM toolset because no DM2 toolset usage requirements were met.")
   ENDIF
   RETURN(dtu_use_dm_toolset)
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
          ELSE
           RETURN(- (19))
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
   ENDIF
   IF (no_par_ind=0)
    SET vc_par = select_merge_translate(cnvtstring(par_cd),"CODE_VALUE")
    IF (vc_par != "No Trans")
     SET to_par = cnvtreal(vc_par)
     SET par_trans_ind = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",par_cd)
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
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_loop].parent_entity_col != ""))
          DECLARE rpt_col_value = vc
          DECLARE rpt_fnd = i4
          DECLARE rpt_srch = i4
          DECLARE rpt_parent_col = vc
          DECLARE rpt_i_domain = vc
          DECLARE rpt_i_name = vc
          DECLARE rpt_data_type = vc
          DECLARE rpt_col_pos = i4
          DECLARE rpt_mult_cnt = i4
          SET rpt_fnd = locateval(rpt_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[rpt_srch].tab_col_name)
          IF (rpt_fnd > 0)
           IF ((rdds_exception->qual[rpt_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[rpt_fnd].tru_col_name="INVALID"))
            SET rpt_table = ""
            SET rpt_column = ""
            SET rpt_from = 0
           ELSE
            SET rpt_table = rdds_exception->qual[rpt_fnd].tru_tab_name
            SET rpt_column = rdds_exception->qual[rpt_fnd].tru_col_name
            CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET rpt_col_value = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
            parent_entity_col)
           CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
           SET rpt_col_pos = locateval(rpt_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
            rpt_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_srch].column_name)
           IF (rpt_col_pos > 0)
            SET rpt_data_type = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_col_pos].
             data_type)
            IF (rpt_data_type IN ("VC", "C*"))
             SET rpt_fnd = 0
             SET rpt_fnd = locateval(rpt_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
              rpt_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_srch].column_name)
             IF (rpt_fnd != 0)
              CALL parser(concat("set rpt_parent_col = cnvtupper(RS_",dm2_ref_data_doc->tbl_qual[
                sbr_tbl_cnt].suffix,"->from_values.",rpt_col_value,") go"),1)
              IF (rpt_parent_col != ""
               AND rpt_parent_col != " ")
               SET rpt_parent_col = find_p_e_col(rpt_parent_col,sbr_loop)
              ELSE
               SET rpt_i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
                table_name)
               SET rpt_i_name = concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
                column_name,":",rpt_parent_col)
               SELECT INTO "NL:"
                FROM dm_info d
                WHERE d.info_domain=rpt_i_domain
                 AND d.info_name=rpt_i_name
                DETAIL
                 rpt_parent_col = d.info_char
                WITH nocounter
               ;end select
              ENDIF
             ENDIF
            ENDIF
           ENDIF
           IF (rpt_parent_col != "INVALIDTABLE"
            AND rpt_parent_col != "")
            SET rpt_table = rpt_parent_col
            SET rpt_fnd = locateval(rpt_srch,1,dguc_reply->rs_tbl_cnt,rpt_table,dguc_reply->dtd_hold[
             rpt_srch].tbl_name)
            IF (rpt_fnd != 0)
             IF ((dguc_reply->dtd_hold[rpt_fnd].pk_cnt >= 1))
              SET rpt_srch = 0
              FOR (rpt_mult_cnt = 1 TO dguc_reply->dtd_hold[rpt_fnd].pk_cnt)
                IF ((((dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*ID")) OR ((((
                dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*CD")) OR ((dguc_reply->
                dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="CODE_VALUE"))) )) )
                 IF ((((dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*ID")) OR ((
                 dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="CODE_VALUE"))) )
                  SET rpt_column = dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name
                  SET rpt_srch = (rpt_srch+ 1)
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             IF (rpt_srch > 1)
              SET rpt_column = ""
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name != ""))
          DECLARE rpt_fnd = i4
          DECLARE rpt_srch = i4
          SET rpt_fnd = locateval(rpt_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[rpt_srch].tab_col_name)
          IF (rpt_fnd > 0)
           IF ((rdds_exception->qual[rpt_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[rpt_fnd].tru_col_name="INVALID"))
            SET rpt_table = ""
            SET rpt_column = ""
            SET rpt_from = 0
           ELSE
            SET rpt_table = rdds_exception->qual[rpt_fnd].tru_tab_name
            SET rpt_column = rdds_exception->qual[rpt_fnd].tru_col_name
            CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET rpt_table = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_name
           SET rpt_column = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_attr
           CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
          ENDIF
         ENDIF
         SET rpt_missing = ""
         IF (rpt_table != ""
          AND rpt_from != 0)
          SET rpt_missing = report_missing(rpt_table,rpt_column,rpt_from)
         ENDIF
         IF (rpt_missing="ORPHAN")
          IF ((((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].unique_ident_ind=1)) OR (
          (((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].pk_ind=1)) OR ((
          dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].merge_delete_ind=1))) )) )
           SET sbr_rpt_orphan_ind = 1
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat(rpt_missing," - ",dm2_ref_data_doc->tbl_qual[
            sbr_tbl_cnt].col_qual[sbr_loop].column_name)
           SET sbr_err_msg = concat(rpt_missing," - ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
            col_qual[sbr_loop].column_name)
           SET sbr_loop = sbr_col_cnt
          ELSE
           SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated = 1
           CALL parser(concat("set rs_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,"->to_values.",
             dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name," = 0 go"),1)
           SET skip_for_orphan_ind = 1
          ENDIF
         ELSEIF (rpt_missing="OLDVER")
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = rpt_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSE
          SET drdm_no_trans_ind = 1
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = concat("This log_id ",
           "wasn't translated because not all columns were translated.")
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
          ROLLBACK
          CALL merge_audit("FAILREASON",sbr_err_msg)
          IF (drdm_error_out_ind=1)
           ROLLBACK
          ELSE
           COMMIT
          ENDIF
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
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
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name=dm2_ref_data_doc->
     tbl_qual[temp_tbl_cnt].col_qual[d.seq].root_entity_attr)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].col_qual[d.seq].root_entity_name))
      sbr_return = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name
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
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_check_log_for_errors(dclfe_op_id=f8,dclfe_oper_logfile=vc,dclfe_force_load_ind=i2,
  dclfe_err_ind=i2(ref)) = i2
 DECLARE dir_load_mixed_table_data(dlmtd_force_load_ind=i2) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dir_get_dmp_log_loc(dgdll_op_id=f8,dgdll_dmp_loc_out=vc(ref)) = i2
 DECLARE dir_load_ref_table_data(force_load_ind=i2) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 IF ((validate(dm2_priority_group_matrix->cnt,- (1))=- (1)))
  FREE RECORD dm2_priority_group_matrix
  RECORD dm2_priority_group_matrix(
    1 cnt = i2
    1 priority_group[*]
      2 group_name = vc
      2 priority_from_range = i4
      2 priority_to_range = i4
      2 group_prefix = c10
  )
  SET dm2_priority_group_matrix->cnt = 0
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE TABLES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 0
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  100
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ct"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE INDEXES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 199
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  400
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ci"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "CREATE CONSTRAINTS"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 399
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  500
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "cc"
  SET dm2_priority_group_matrix->cnt = (dm2_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(dm2_priority_group_matrix->priority_group,dm2_priority_group_matrix->cnt)
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_name =
  "RUN UTILITIES"
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_from_range
   = 699
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].priority_to_range =
  800
  SET dm2_priority_group_matrix->priority_group[dm2_priority_group_matrix->cnt].group_prefix = "ru"
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
 IF (validate(dir_clin_copy_data->process,"x")="x"
  AND validate(dir_clin_copy_data->process,"y")="y")
  FREE RECORD dir_clin_copy_data
  RECORD dir_clin_copy_data(
    1 process = vc
    1 export_location = vc
    1 schema_date = dq8
    1 ref_par_file_cnt = i2
    1 summary_par_file_name = vc
    1 mixed_tables_parfile_name = vc
    1 ref_parfile_prefix = vc
    1 ind_mixed_parfile_prefix = vc
    1 exp_file_prefix = vc
    1 imp_file_prefix = vc
    1 export_rpt_name = vc
    1 import_rpt_name = vc
  )
  SET dir_clin_copy_data->process = "DM2NOTSET"
  SET dir_clin_copy_data->export_location = "DM2NOTSET"
  SET dir_clin_copy_data->ref_par_file_cnt = 0
  SET dir_clin_copy_data->summary_par_file_name = "dm2_ref_parfile_summary.dat"
  SET dir_clin_copy_data->mixed_tables_parfile_name = "dm2_mixed_tables.par"
  SET dir_clin_copy_data->ref_parfile_prefix = "dm2_reference_tables_"
  SET dir_clin_copy_data->ind_mixed_parfile_prefix = "dm2_mixtbl_"
  SET dir_clin_copy_data->exp_file_prefix = "exp_v500"
  SET dir_clin_copy_data->imp_file_prefix = "imp_v500"
  SET dir_clin_copy_data->exp_file_prefix = "dm2_export"
  SET dir_clin_copy_data->imp_file_prefix = "dm2_import"
 ENDIF
 IF (validate(dir_mixed_tables_data->cnt,1)=1
  AND validate(dir_mixed_tables_data->cnt,2)=2)
  FREE RECORD dir_mixed_tables_data
  RECORD dir_mixed_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 table_suffix = vc
      2 where_clause_cnt = i2
      2 qual[*]
        3 process_type = vc
        3 data_type = vc
        3 where_clause = vc
      2 prefix = vc
  )
  SET dir_mixed_tables_data->cnt = 0
 ENDIF
 IF (validate(dir_ignored_errors->cnt,1)=1
  AND validate(dir_ignored_errors->cnt,2)=2)
  FREE RECORD dir_ignored_errors
  RECORD dir_ignored_errors(
    1 cnt = i4
    1 dir_ignorable_errfile = vc
    1 qual[*]
      2 error = vc
  )
  SET dir_ignored_errors->cnt = 0
  SET dir_ignored_errors->dir_ignorable_errfile = "dm2_ignorable_errors.dat"
 ENDIF
 IF (validate(dir_errors_encountered->cmd_cnt,1)=1
  AND validate(dir_errors_encountered->cmd_cnt,2)=2)
  FREE RECORD dir_errors_encountered
  RECORD dir_errors_encountered(
    1 cmd_cnt = i4
    1 qual[*]
      2 dee_op_id = f8
      2 error_cnt = i4
      2 logfile_name = vc
      2 qual[*]
        3 error = vc
        3 error_desc = vc
  )
  SET dir_errors_encountered->cmd_cnt = 0
 ENDIF
 IF (validate(dir_ref_tables_data->cnt,1)=1
  AND validate(dir_ref_tables_data->cnt,2)=2)
  FREE RECORD dir_ref_tables_data
  RECORD dir_ref_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET dir_ref_tables_data->cnt = 0
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
 SUBROUTINE dir_get_dmp_log_loc(dgdll_op_id,dgdll_dmp_loc_out)
   DECLARE dgdll_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Find logfile for OP_ID:",build(dgdll_op_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.op_id=dgdll_op_id
    DETAIL
     dgdll_strt_pt = (findstring("log=",d.operation,1)+ 4), dgdll_end_pt = findstring(" ",d.operation,
      dgdll_strt_pt), dgdll_dmp_loc_out = substring(dgdll_strt_pt,(dgdll_end_pt - dgdll_strt_pt),d
      .operation)
     IF ((dm_err->debug_flag > 2))
      CALL echo(d.operation),
      CALL echo(dgdll_strt_pt),
      CALL echo(dgdll_end_pt),
      CALL echo(dgdll_dmp_loc_out)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgdll_dmp_loc_out = "NOT_VALID_OP_ID"
   ELSE
    IF (dgdll_dmp_loc_out > " ")
     IF (findfile(dgdll_dmp_loc_out)=0)
      SET dgdll_dmp_loc_out = concat("NO_FILE_IN_OS:",dgdll_dmp_loc_out)
     ENDIF
    ELSE
     SET dgdll_dmp_loc_out = "NO_FILE_IN_COMMAND"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_ref_table_data(force_load_ind)
   DECLARE dlrtd_mix_ndx = i4 WITH protect, noconstant(0)
   IF ((dir_ref_tables_data->cnt > 0)
    AND force_load_ind=0)
    SET dm_err->eproc = "Skipping load of reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dir_load_mixed_table_data(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading reference table list."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dir_ref_tables_data->cnt = 0
   SET stat = alterlist(dir_ref_tables_data->tbl,dir_ref_tables_data->cnt)
   SELECT INTO "nl:"
    dut.table_name
    FROM dm_tables_doc dtd,
     dm2_user_tables dut
    PLAN (dtd
     WHERE dtd.table_name=dtd.full_table_name
      AND dtd.reference_ind=1)
     JOIN (dut
     WHERE dut.table_name=dtd.table_name)
    ORDER BY dut.table_name
    DETAIL
     IF (locateval(dlrtd_mix_ndx,1,value(dir_mixed_tables_data->cnt),dut.table_name,
      dir_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name)=0)
      dir_ref_tables_data->cnt = (dir_ref_tables_data->cnt+ 1)
      IF (mod(dir_ref_tables_data->cnt,2000)=1)
       stat = alterlist(dir_ref_tables_data->tbl,(dir_ref_tables_data->cnt+ 1999))
      ENDIF
      dir_ref_tables_data->tbl[dir_ref_tables_data->cnt].table_name = dut.table_name
     ELSE
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(dut.table_name),
        " is a mixed table and not loaded into Reference listing."))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dir_ref_tables_data->tbl,dir_ref_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dir_ref_tables_data->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking count of reference tables."
    SET dm_err->emsg = "No reference tables found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_ref_tables_data)
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
 SUBROUTINE dir_check_log_for_errors(dclfe_op_id,dclfe_oper_logfile,dclfe_force_load_ind,
  dclfe_err_ind)
   DECLARE dclfe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_type = vc WITH protect, noconstant("")
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_add_cmd = i2 WITH protect, noconstant(1)
   DECLARE dclfe_err_cnt = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Check if ignorable errors file exists."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (findfile(value(dir_ignored_errors->dir_ignorable_errfile)) > 0)
    SET dm_err->eproc = "Load ignorable errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    DEFINE rtl2 value(dir_ignored_errors->dir_ignorable_errfile)
    SELECT INTO "nl:"
     FROM rtl2t t
     WHERE t.line > " "
     HEAD REPORT
      dir_ignored_errors->cnt = 0
     DETAIL
      dir_ignored_errors->cnt = (dir_ignored_errors->cnt+ 1)
      IF (mod(dir_ignored_errors->cnt,10)=1)
       stat = alterlist(dir_ignored_errors->qual,(dir_ignored_errors->cnt+ 9))
      ENDIF
      dir_ignored_errors->qual[dir_ignored_errors->cnt].error = trim(t.line)
     FOOT REPORT
      stat = alterlist(dir_ignored_errors->qual,dir_ignored_errors->cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_ignored_errors)
   ENDIF
   IF (dclfe_force_load_ind=1)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("Resetting error structure due to force load ind",dm_err->logfile,0)
    ENDIF
    FOR (dclfe_err_cnt = 1 TO size(dir_errors_encountered->qual,5))
      SET stat = alterlist(dir_errors_encountered->qual[dclfe_err_cnt].qual,0)
    ENDFOR
    SET stat = alterlist(dir_errors_encountered->qual,0)
    SET dclfe_err_cnt = 0
    SET dir_errors_encountered->cmd_cnt = 0
   ENDIF
   SET dm_err->eproc = "Check Operation Logfile for Errors."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   FREE DEFINE rtl2
   SET logical dclfe_operlogfile_logical dclfe_oper_logfile
   DEFINE rtl2 "dclfe_operlogfile_logical"
   SELECT INTO "nl:"
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
     dclfe_end = 0, dclfe_err_str = ""
     IF (findstring("ORA-",t.line,0) > 0)
      dclfe_err_type = "ORA-"
     ELSEIF (findstring("EXP-",t.line,0) > 0)
      dclfe_err_type = "EXP-"
     ELSEIF (findstring("IMP-",t.line,0) > 0)
      dclfe_err_type = "IMP-"
     ELSEIF (findstring("LOG FILE NOT FOUND",t.line,0) > 0)
      dclfe_err_type = "OTHER"
     ENDIF
     IF (dclfe_err_type > "")
      IF (dclfe_err_type="OTHER")
       dclfe_err_str = "", dclfe_end = 1
      ELSE
       dclfe_start = findstring(dclfe_err_type,t.line,0), dclfe_end = findstring(" ",t.line,
        dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start) - 1),t.line)
      ENDIF
      dclfe_ndx = 0
      IF (locateval(dclfe_ndx,1,dir_ignored_errors->cnt,dclfe_err_str,dir_ignored_errors->qual[
       dclfe_ndx].error)=0)
       IF (dclfe_add_cmd=1)
        dclfe_err_ind = 1, dir_errors_encountered->cmd_cnt = (dir_errors_encountered->cmd_cnt+ 1),
        stat = alterlist(dir_errors_encountered->qual,dir_errors_encountered->cmd_cnt),
        dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].logfile_name =
        dclfe_oper_logfile, dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].dee_op_id
         = dclfe_op_id, dclfe_add_cmd = 0
       ENDIF
       dclfe_ndx = 0
       IF (locateval(dclfe_ndx,1,dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].
        error_cnt,dclfe_err_str,dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[
        dclfe_ndx].error)=0)
        dclfe_err_cnt = (dclfe_err_cnt+ 1), dir_errors_encountered->qual[dir_errors_encountered->
        cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(dir_errors_encountered->qual[
         dir_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
        dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
        dclfe_err_str, dir_errors_encountered->qual[dir_errors_encountered->cmd_cnt].qual[
        dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(t.line)) - dclfe_end),t.line)
       ELSE
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
        ENDIF
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("Ignored error:",dir_ignored_errors->qual[dclfe_ndx].error," from file:",
         dclfe_oper_logfile))
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_errors_encountered)
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_mixed_table_data(dlmtd_force_load_ind)
   DECLARE dlmtd_start = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_end = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_qual_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get mixed tables"
   IF ((dir_mixed_tables_data->cnt > 0)
    AND dlmtd_force_load_ind=0)
    RETURN(1)
   ENDIF
   SET dir_mixed_tables_data->cnt = 0
   SET stat = alterlist(dir_mixed_tables_data->tbl,0)
   SELECT INTO "nl:"
    FROM dm_info di,
     dm2_user_tables dut,
     dm_tables_doc dtd
    PLAN (di
     WHERE di.info_domain="DM2_MIXED_TABLE-*")
     JOIN (dut
     WHERE di.info_name=dut.table_name)
     JOIN (dtd
     WHERE dut.table_name=dtd.table_name)
    ORDER BY di.info_name
    HEAD di.info_name
     dir_mixed_tables_data->cnt = (dir_mixed_tables_data->cnt+ 1)
     IF (mod(dir_mixed_tables_data->cnt,10)=1)
      stat = alterlist(dir_mixed_tables_data->tbl,(dir_mixed_tables_data->cnt+ 9))
     ENDIF
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].table_name = di.info_name,
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].table_suffix = dtd.table_suffix,
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].prefix = cnvtlower(build(
       dir_clin_copy_data->ind_mixed_parfile_prefix,dtd.table_suffix)),
     dlmtd_qual_cnt = 0
    DETAIL
     dlmtd_qual_cnt = (dlmtd_qual_cnt+ 1)
     IF (mod(dlmtd_qual_cnt,10)=1)
      stat = alterlist(dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual,(dlmtd_qual_cnt+ 9
       ))
     ENDIF
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].where_clause = di
     .info_char, dlmtd_start = 0, dlmtd_end = 0,
     dlmtd_start = (findstring("-",trim(di.info_domain),0)+ 1), dlmtd_end = findstring("-",trim(di
       .info_domain),dlmtd_start,1), dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[
     dlmtd_qual_cnt].process_type = substring(dlmtd_start,(dlmtd_end - dlmtd_start),di.info_domain),
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].data_type =
     substring((dlmtd_end+ 1),(size(trim(di.info_domain)) - dlmtd_start),trim(di.info_domain))
    FOOT  di.info_name
     stat = alterlist(dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].qual,dlmtd_qual_cnt),
     dir_mixed_tables_data->tbl[dir_mixed_tables_data->cnt].where_clause_cnt = dlmtd_qual_cnt
    FOOT REPORT
     stat = alterlist(dir_mixed_tables_data->tbl,dir_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Mixed Tables Exist in DM_INFO."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dir_mixed_tables_data)
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
    FROM dm2_user_tables t
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
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE') ")
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
        SET dcsa_error_msg = concat("Application Id ",trim(dcsa_fmt_appl_id))
        SET dcsa_error_msg = concat(dcsa_error_msg," is no longer active.")
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN ("RUNNING", null)
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
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF (cursys != "AXP")
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
    1 loop_back_ind = i2
    1 qual[*]
      2 pattern_cki = vc
  )
  SET dm2_ref_data_doc->env_target_id = - (1)
  SET dm2_ref_data_doc->env_source_id = - (1)
  SET dm2_ref_data_doc->mock_target_id = - (1)
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
     SET dm_err->err_msg = "Error returned from Versiong Alg UAR."
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
     CALL disp_msg("No code_set qualified from dm_tables_doc",dm_err->logfile,0)
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
   SELECT INTO "NL:"
    FROM dm_tables_doc dtd
    WHERE dtd.table_name=sbr_gtci_tname
    DETAIL
     temp_tbl_cnt = (perm_tbl_cnt+ 1), perm_tbl_cnt = (perm_tbl_cnt+ 1), stat = alterlist(
      dm2_ref_data_doc->tbl_qual,value((size(dm2_ref_data_doc->tbl_qual,5)+ 1))),
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name = dtd.table_name
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name IN ("ACCESSION", "ADDRESS", "PHONE",
     "PERSON", "PERSON_NAME",
     "PERSON_ALIAS", "DCP_ENTITY_RELTN", "LONG_TEXT", "LONG_BLOB", "ACCOUNT",
     "AT_ACCT_RELTN")))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = 1, dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].reference_ind = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = dtd.mergeable_ind, dm2_ref_data_doc->
      tbl_qual[temp_tbl_cnt].reference_ind = dtd.reference_ind
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix = dtd.table_suffix, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].merge_ui_query = dtd.merge_ui_query, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
     merge_delete_ind = dtd.merge_delete_ind
     IF (dtd.merge_ui_query=null)
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
     CALL disp_msg("No table qualified from dm_tables_doc",dm_err->logfile,1)
    ENDIF
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Loading column level info into memory for table ",sbr_gtci_tname)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF ((dm2_rdds_rec->mode="OS"))
     FROM (parser(src_tab_name) utc),
      dm_columns_doc dcd,
      user_tab_columns ut
     PLAN (utc
      WHERE utc.table_name=sbr_gtci_tname)
      JOIN (dcd
      WHERE dcd.table_name=utc.table_name
       AND dcd.column_name=utc.column_name)
      JOIN (ut
      WHERE ut.table_name=dcd.table_name
       AND ut.column_name=dcd.column_name)
    ELSE
     FROM dm_columns_doc dcd,
      (parser(src_tab_name) utc)
     PLAN (dcd
      WHERE dcd.table_name=sbr_gtci_tname)
      JOIN (utc
      WHERE utc.table_name=dcd.table_name
       AND utc.column_name=dcd.column_name)
    ENDIF
    INTO "nl:"
    DETAIL
     col_qual_cnt = (col_qual_cnt+ 1)
     IF (mod(col_qual_cnt,10)=1)
      stat = alterlist(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,(col_qual_cnt+ 9))
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].column_name = dcd.column_name,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].unique_ident_ind = dcd
     .unique_ident_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].exception_flg
      = dcd.exception_flg,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].constant_value = dcd
     .constant_value, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
     parent_entity_col = cnvtupper(dcd.parent_entity_col), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
     col_qual[col_qual_cnt].sequence_name = dcd.sequence_name,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].root_entity_name = cnvtupper(dcd
      .root_entity_name), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
     root_entity_attr = cnvtupper(dcd.root_entity_attr), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
     col_qual[col_qual_cnt].code_set = dcd.code_set,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_type = utc.data_type,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_length = utc.data_length,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].nullable = utc.nullable,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].check_null = 0, dm2_ref_data_doc
     ->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].translated = 0, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].col_qual[col_qual_cnt].merge_delete_ind = dcd.merge_delete_ind,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default = utc.data_default,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = nullind(utc
      .data_default)
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni=0))
      IF (((cnvtupper(utc.data_default)="NULL") OR (((utc.data_default=" ") OR (((utc.data_default=""
      ) OR (((utc.data_default="''") OR (utc.data_default='""')) )) )) )) )
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = 1
      ENDIF
     ENDIF
     IF (dcd.column_name IN ("*_ID", "*_CD", "CODE_VALUE"))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 0
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
     CALL disp_msg("No columns qualified from dm_columns_doc",dm_err->logfile,1)
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
 DECLARE ins_upd_ind = i2
 DECLARE from_species_cd = vc
 DECLARE new_species_cd = vc
 DECLARE col_num = i4
 DECLARE index_var = i4
 DECLARE ui_cnt = i4
 DECLARE no_query = i2
 DECLARE val = f8
 DECLARE ins_upd = i2
 DECLARE idcd_check = i2
 DECLARE nom_num = i4
 DECLARE nvg_num = i4
 DECLARE cust_to_nvg = vc
 DECLARE cust_tab_name = vc
 DECLARE nom_imt_check = i2
 SET cust_tab_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
 SET nom_num = get_col_pos(cust_tab_name,"NOMENCLATURE_ID")
 SET nvg_num = get_col_pos(cust_tab_name,"NOM_VER_GRP_ID")
 IF ((dm2_ref_data_reply->error_ind=1))
  GO TO exit_2968
 ENDIF
 SET temp_col_cnt = get_col_pos(cust_tab_name,"NOMENCLATURE_ID")
 IF ((dm2_ref_data_reply->error_ind=1))
  GO TO exit_2968
 ENDIF
 IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].translated=0))
  SET no_query = is_translated(cust_tab_name,"UNIQUE")
  IF (no_query=1)
   SET val = query_target(temp_tbl_cnt,perm_col_cnt)
   IF (val < 0)
    IF ((val=- (3)))
     SET val = get_seq(cust_tab_name,"NOMENCLATURE_ID")
     IF (val > 0)
      CALL put_value(cust_tab_name,"NOMENCLATURE_ID",cnvtstring(val))
      SET current_merges = (current_merges+ 1)
      SET child_merge_audit->num[current_merges].action = "NEWSEQ"
      SET child_merge_audit->num[current_merges].text = concat(cust_tab_name,"  NOMENCLATURE_ID")
     ELSE
      GO TO exit_2968
     ENDIF
    ELSE
     GO TO exit_2968
    ENDIF
   ELSE
    CALL put_value(cust_tab_name,"NOMENCLATURE_ID",cnvtstring(val))
   ENDIF
   SET from_species_cd = get_value(cust_tab_name,"NOMENCLATURE_ID","FROM")
   IF ((dm2_ref_data_reply->error_ind=1))
    GO TO exit_2968
   ENDIF
   SET new_species_cd = get_value(cust_tab_name,"NOMENCLATURE_ID","TO")
   IF ((dm2_ref_data_reply->error_ind=1))
    GO TO exit_2968
   ELSE
    SET nom_imt_check = insert_merge_translate(cnvtreal(from_species_cd),cnvtreal(new_species_cd),
     "NOMENCLATURE")
    IF (nom_imt_check=1)
     GO TO exit_2968
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[nvg_num].translated=0))
    SET cust_to_nvg = select_merge_translate(cnvtstring(rs_2968->from_values.nom_ver_grp_id),
     "NOMENCLATURE")
    IF (cust_to_nvg="No Trans")
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg =
     "DM2_REF_DATA_MOVER_2968: NOM_VER_GRP_ID was not translated."
    ELSE
     CALL put_value(cust_tab_name,"NOM_VER_GRP_ID",cust_to_nvg)
    ENDIF
   ENDIF
   CALL echo(build("P COLUMN = ",curmem))
  ELSE
   SET idcd_check = is_translated(cust_tab_name,"ALL")
   GO TO exit_2968
  ENDIF
 ENDIF
 SET idcd_check = 0
 CALL echo("")
 CALL echo("")
 CALL echo("***************CHECKING ID AND CD COLUMNS******************")
 CALL echo("")
 CALL echo("")
 SET dm_err->eproc = "Checking ID and CD columns"
 SET idcd_check = is_translated(cust_tab_name,"ALL")
 IF (drdm_error_out_ind=1)
  GO TO exit_2968
 ENDIF
 SET dm_err->eproc = "Status of translation"
 IF (idcd_check=1)
  SET ins_upd = insert_update_row(temp_tbl_cnt,perm_col_cnt)
  CALL echo(build("p Insert = ",curmem))
 ELSE
  SET current_merges = 0
  ROLLBACK
 ENDIF
#exit_2968
 FREE SET from_species_cd
 FREE SET new_species_cd
 FREE SET ins_upd_ind
 FREE SET col_num
 FREE SET index_var
 FREE SET ui_cnt
 FREE SET rrf_col
 FREE SET no_query
 FREE SET val
 FREE SET ins_upd
 FREE SET idcd_check
 FREE SET cust_rrf_loop
 FREE SET cust_tab_name
 FREE SET bad_species_cd
END GO
