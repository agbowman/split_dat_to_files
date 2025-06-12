CREATE PROGRAM dm_rmc_generate_cutover_dml:dba
 DECLARE add_stmt(i_str=vc,i_rdb_asis_ind=i2,i_end_ind=i2,i_move_long_str_ind=i2,io_stmt_cnt=i4(ref),
  io_rs_stmts=vc(ref)) = null
 SUBROUTINE add_stmt(i_str,i_rdb_asis_ind,i_end_ind,i_move_long_str_ind,io_stmt_cnt,io_rs_stmts)
   DECLARE s_max_length = i4 WITH protect
   DECLARE s_start = i4 WITH protect
   DECLARE s_str_len = i4 WITH protect
   DECLARE s_str = vc WITH protect, noconstant("")
   SET s_str = i_str
   SET s_max_length = 130
   IF (i_rdb_asis_ind=1)
    SET s_max_length = (s_max_length - 15)
    IF (findstring("v_curdate",s_str) > 0)
     SET s_max_length = (s_max_length - 50)
    ENDIF
   ENDIF
   IF (i_end_ind=1)
    SET s_max_length = (s_max_length - 7)
   ENDIF
   SET s_start = 1
   SET s_str_len = size(s_str,1)
   WHILE (s_start <= s_str_len)
    SET s_break_pos = findstring("<BrEaK>",substring(s_start,s_max_length,s_str),1,0)
    IF (s_break_pos > 0)
     SET s_break_pos = (s_break_pos - 1)
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_break_pos,s_str)
     SET s_start = ((s_start+ s_break_pos)+ 7)
    ELSEIF ((((s_str_len - s_start)+ 1) <= s_max_length))
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,((s_str_len - s_start)+ 1),s_str)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = i_end_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET s_start = (s_str_len+ 1)
    ELSE
     SET s_space_pos = findstring(" ",substring(s_start,s_max_length,s_str),1,1)
     IF (s_space_pos=0)
      CALL echo(substring(s_start,s_max_length,s_str))
      RETURN
     ENDIF
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_space_pos,s_str)
     SET s_start = (s_start+ s_space_pos)
    ENDIF
   ENDWHILE
 END ;Subroutine
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 DECLARE cutover_get_and_run_dml(i_table_name=vc,i_source_env_id=f8,i_move_long_ind=i2,i_batch_ind=i2,
  i_tgt_env_id=f8) = vc
 DECLARE create_merge_strs(i_tab_info=vc(ref)) = null
 DECLARE create_merge_stmts(i_table_name=vc,o_rs_stmts=vc(ref)) = null
 DECLARE get_meta_data(gmd_table_name=vc,gmd_tab_info=vc(ref)) = null
 DECLARE init_rs_data(ird_info=vc(ref)) = null
 DECLARE pk_data_default(i_tab_info=vc(ref),i_col_ndx=i4) = null
 DECLARE hextoraw() = vc
 DECLARE to_clob() = vc
 SUBROUTINE create_merge_stmts(i_table_name,o_rs_stmts)
   DECLARE v_temp_where_str = vc
   DECLARE v_vers_where_str = vc
   DECLARE v_ui_check_str = vc
   DECLARE v_merge_str = vc
   DECLARE v_delete_str = vc
   DECLARE v_insert_str = vc
   DECLARE v_update_str = vc
   DECLARE s_stmt_cnt = i4
   DECLARE delete_sel_str = vc
   DECLARE v_rdds_where_string = vc WITH protect
   DECLARE v_rdds_where_iu_string = vc WITH protect
   DECLARE v_rdds_where_del_string = vc WITH protect
   IF ((validate(drcd_debug_ind,- (1))=- (1)))
    DECLARE drcd_debug_ind = i2 WITH protect, constant(0)
   ENDIF
   DECLARE drcd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE col_ndx = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_col_loop = i4 WITH protect, noconstant(0)
   DECLARE drcd_col_loop = i4 WITH protect, noconstant(0)
   DECLARE v_mover_string = vc
   DECLARE v_mover_alg5_string = vc
   DECLARE v_mvr_ind = i2
   DECLARE v_mvr_ch_ind = i2
   DECLARE drs_date_default = vc
   DECLARE drs_mon = vc
   DECLARE type_ndx = i4
   DECLARE cms_num = i4 WITH protect
   DECLARE cms_eff_str = vc WITH protect, noconstant("")
   DECLARE cms_type = vc WITH protect, noconstant("")
   DECLARE cms_sect_ndx = i4 WITH protect, noconstant(0)
   DECLARE v_upd1_sect2_dml = vc WITH protect, noconstant(" ")
   DECLARE v_ins1_sect1_dml = vc WITH protect, noconstant(" ")
   DECLARE cms_tier_cell_idx = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_col_idx = i4 WITH protect, noconstant(0)
   DECLARE drcd_temp_set_stmt = vc WITH protect, noconstant("")
   DECLARE drcd_temp_col_str = vc WITH protect, noconstant(" ")
   DECLARE drcd_temp_match_str = vc WITH protect, noconstant(" ")
   FREE RECORD tab_info
   RECORD tab_info(
     1 table_name = vc
     1 tab_$r = vc
     1 r_tab_exists = i2
     1 table_suffix = vc
     1 merge_delete_ind = i2
     1 versioning_ind = i2
     1 version_cdf = vc
     1 beg_eff_col_ndx = i4
     1 end_eff_col_ndx = i4
     1 pk_col_ndx = i4
     1 prev_pk_col_ndx = i4
     1 ui_match_str = vc
     1 ui_match_str_ovr = vc
     1 pk_diff_str = vc
     1 pk_match_str = vc
     1 pk_long_str = vc
     1 ui_col_list = vc
     1 ui_col_list_ovr = vc
     1 all_upd_val_str = vc
     1 all_ins_val_str = vc
     1 tm_all_upd_val_str = vc
     1 tm_all_ins_val_str = vc
     1 updt_upd_val_str = vc
     1 updt_col_list = vc
     1 updt_val_list = vc
     1 col_list = vc
     1 md_col_list = vc
     1 pk_col_list = vc
     1 default_row_str = vc
     1 long_call = vc
     1 long_pk_str = vc
     1 exception_flg9_ind = i2
     1 nullable_ui_ind = i2
     1 upd_col_list = vc
     1 upd_val_list = vc
     1 grouper_col_list = vc
     1 grouper_match_str = vc
     1 user_dt_tm_ind = i2
     1 static_active_ind = i2
     1 cols[*]
       2 long_ind = i2
       2 column_name = vc
       2 parent_entity_col = vc
       2 exception_flg = i4
       2 upd_val_str = vc
       2 ins_val_str = vc
       2 ident_ind = i2
       2 pk_ind = i2
       2 grouper_col_ind = i2
       2 md_ind = i2
       2 data_type = vc
       2 ccl_type = vc
       2 nullable = c1
       2 data_default = vc
       2 data_default_null_ind = i2
       2 sequence_name = vc
       2 circ_cnt = i4
       2 self_entity_name = vc
       2 circ_qual[*]
         3 circ_table_name = vc
         3 circ_pk_col_name = vc
         3 circ_fk_col_name = vc
         3 circ_entity_col_name = vc
   )
   FREE RECORD other_info
   RECORD other_info(
     1 table_name = vc
     1 tab_$r = vc
     1 r_tab_exists = i2
     1 table_suffix = vc
     1 merge_delete_ind = i2
     1 versioning_ind = i2
     1 version_cdf = vc
     1 beg_eff_col_ndx = i4
     1 end_eff_col_ndx = i4
     1 pk_col_ndx = i4
     1 prev_pk_col_ndx = i4
     1 ui_match_str = vc
     1 ui_match_str_ovr = vc
     1 pk_diff_str = vc
     1 pk_match_str = vc
     1 pk_long_str = vc
     1 ui_col_list = vc
     1 ui_col_list_ovr = vc
     1 all_upd_val_str = vc
     1 all_ins_val_str = vc
     1 tm_all_upd_val_str = vc
     1 tm_all_ins_val_str = vc
     1 updt_upd_val_str = vc
     1 updt_col_list = vc
     1 updt_val_list = vc
     1 col_list = vc
     1 md_col_list = vc
     1 pk_col_list = vc
     1 default_row_str = vc
     1 long_call = vc
     1 long_pk_str = vc
     1 exception_flg9_ind = i2
     1 nullable_ui_ind = i2
     1 upd_col_list = vc
     1 upd_val_list = vc
     1 grouper_col_list = vc
     1 grouper_match_str = vc
     1 user_dt_tm_ind = i2
     1 static_active_ind = i2
     1 cols[*]
       2 long_ind = i2
       2 column_name = vc
       2 parent_entity_col = vc
       2 exception_flg = i4
       2 upd_val_str = vc
       2 ins_val_str = vc
       2 ident_ind = i2
       2 pk_ind = i2
       2 grouper_col_ind = i2
       2 md_ind = i2
       2 data_type = vc
       2 ccl_type = vc
       2 nullable = c1
       2 data_default = vc
       2 data_default_null_ind = i2
       2 sequence_name = vc
       2 circ_cnt = i4
       2 self_entity_name = vc
       2 circ_qual[*]
         3 circ_table_name = vc
         3 circ_pk_col_name = vc
         3 circ_fk_col_name = vc
         3 circ_entity_col_name = vc
   )
   FREE RECORD drcd_orig_str
   RECORD drcd_orig_str(
     1 cols[*]
       2 str = vc
   )
   FREE RECORD dml_stmts
   RECORD dml_stmts(
     1 total = i4
     1 qual[*]
       2 type = vc
       2 stmt_cnt = i4
       2 stmt[*]
         3 stmt_text = vc
         3 stmt_section = i4
   ) WITH protect
   SET stat = alterlist(o_rs_stmts->stmt,0)
   SET s_stmt_cnt = 0
   SET v_rdds_where_str = concat(
    "rdds_context_name =v_context_to_set and rdds_source_env_id =v_source_env_id ",
    "and rdds_status_flag =v_status_flag"," and rowid=rbr_rowid")
   SET v_rdds_where_iu_str = concat("rdds_delete_ind = 0 and ",v_rdds_where_str)
   SET v_rdds_where_del_str = concat("rdds_delete_ind = 1 and ",v_rdds_where_str)
   CALL get_meta_data(i_table_name,tab_info)
   IF ((dm_err->err_ind=1))
    RETURN
   ENDIF
   IF ((tab_info->r_tab_exists=0))
    SET dm_err->emsg = build("****Table not found: ",tab_info->tab_$r,"****")
    SET dm_err->err_ind = 1
    RETURN
   ELSEIF (drcd_debug_ind != 1)
    SELECT INTO "nl:"
     FROM (parser(tab_info->tab_$r))
     WHERE (rdds_source_env_id=o_rs_stmts->source_env_id)
      AND rdds_status_flag < 9000
    ;end select
    IF (check_error(concat("Checking if rows need to be processed for ",tab_info->tab_$r))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->emsg = build("****No rows to process for table: ",tab_info->tab_$r,"****")
     SET dm_err->err_ind = 0
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Gathering DML extensions from DM_INFO."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CUTOVER DML::*"
     AND di.info_name=i_table_name
    ORDER BY di.info_domain
    DETAIL
     cms_type = substring(19,7,di.info_domain), type_ndx = locateval(cms_num,1,dml_stmts->total,
      cms_type,dml_stmts->qual[cms_num].type)
     IF (type_ndx=0)
      dml_stmts->total = (dml_stmts->total+ 1), stat = alterlist(dml_stmts->qual,dml_stmts->total),
      type_ndx = dml_stmts->total,
      dml_stmts->qual[type_ndx].type = cms_type
     ENDIF
     dml_stmts->qual[type_ndx].stmt_cnt = (dml_stmts->qual[type_ndx].stmt_cnt+ 1), stat = alterlist(
      dml_stmts->qual[type_ndx].stmt,dml_stmts->qual[type_ndx].stmt_cnt), dml_stmts->qual[type_ndx].
     stmt[dml_stmts->qual[type_ndx].stmt_cnt].stmt_text = di.info_char,
     dml_stmts->qual[type_ndx].stmt[dml_stmts->qual[type_ndx].stmt_cnt].stmt_section = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN
   ENDIF
   SET type_ndx = locateval(cms_num,1,dml_stmts->total,"UPDATE1",dml_stmts->qual[cms_num].type)
   IF (type_ndx > 0)
    SET cms_sect_ndx = locateval(cms_num,1,dml_stmts->qual[type_ndx].stmt_cnt,2,dml_stmts->qual[
     type_ndx].stmt[cms_num].stmt_section)
    IF (cms_sect_ndx > 0)
     SET v_upd1_sect2_dml = concat(" and ",dml_stmts->qual[type_ndx].stmt[cms_sect_ndx].stmt_text)
    ENDIF
   ENDIF
   SET type_ndx = locateval(cms_num,1,dml_stmts->total,"INSERT1",dml_stmts->qual[cms_num].type)
   IF (type_ndx > 0)
    SET cms_sect_ndx = locateval(cms_num,1,dml_stmts->qual[type_ndx].stmt_cnt,1,dml_stmts->qual[
     type_ndx].stmt[cms_num].stmt_section)
    IF (cms_sect_ndx > 0)
     SET v_ins1_sect1_dml = concat(" and ",dml_stmts->qual[type_ndx].stmt[cms_sect_ndx].stmt_text)
    ENDIF
   ENDIF
   CALL create_merge_strs(tab_info)
   SET v_mvr_ind = 0
   SELECT INTO "nl:"
    FROM dm_refchg_filter_test dr
    WHERE (dr.table_name=tab_info->table_name)
     AND trim(dr.mover_string) > " "
     AND dr.active_ind=1
    DETAIL
     v_mover_string = dr.mover_string
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the mover_string for: ",tab_info->table_name))=1)
    CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual != 0)
    SET v_mover_string = replace(v_mover_string,"<SUFFIX>.","",0)
    SET v_mover_string = replace(v_mover_string,"<MERGE LINK>","",0)
    SET v_mvr_ind = 1
   ENDIF
   IF ((tab_info->merge_delete_ind=0))
    IF ((tab_info->table_name="SEG_GRP_SEQ_R"))
     SET v_delete_str = concat("delete from seg_grp_seq_r s where s.seg_cd IN ",
      "(select sr1.seg_cd from segment_reference sr1"," where sr1.seg_grp_cd in ",
      "(select sr2.seg_grp_cd from segment_reference sr2 ","where sr2.seg_cd in ",
      "(select r.seg_cd from seg_grp_seq_r3292$R r where ",v_rdds_where_iu_str," )))")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_delete_str = concat("delete from seg_grp_seq_r s where s.seg_grp_seq_r_id IN ",
      "(select r.seg_grp_seq_r_id from seg_grp_seq_r3292$R r where ",v_rdds_where_str," )")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ELSE
     SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
      pk_col_list,") in (select ",
      tab_info->pk_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_del_str,
      ") ")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
   ENDIF
   IF ((tab_info->table_name="TIER_MATRIX"))
    SET cms_tier_cell_idx = locateval(cms_num,1,size(tab_info->cols),"TIER_CELL_ID",tab_info->cols[
     cms_num].column_name)
    IF ((tab_info->cols[cms_tier_cell_idx].exception_flg != 6))
     SET v_update_str = concat("update into ",tab_info->table_name," set ",tab_info->cols[tab_info->
      end_eff_col_ndx].column_name," = v_midminus1 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and v_curdate between ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name," and ",
      tab_info->cols[tab_info->end_eff_col_ndx].column_name,
      " and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind =0 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and v_curdate between ",tab_info->cols[
      tab_info->beg_eff_col_ndx].column_name," and ",tab_info->cols[tab_info->end_eff_col_ndx].
      column_name,
      " and active_ind = 1 ")
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->tm_all_upd_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      " and ",tab_info->pk_match_str,")"," where list(",tab_info->pk_col_list,
      ") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r," r_A where ",
      v_temp_where_str,")")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->tm_all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate "," and active_ind = 1 ")
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      " and ",tab_info->pk_match_str,")"," where list(",tab_info->pk_col_list,
      ") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r," r_A where ",
      v_temp_where_str,")")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ELSE
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind =0 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," t1 set (t1.",tab_info->cols[
      tab_info->end_eff_col_ndx].column_name)
     IF (daf_is_not_blank(tab_info->updt_col_list))
      SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
     ENDIF
     SET v_update_str = concat(v_update_str,") (select min(trunc(",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name,")-1/(24*60*60)) ")
     IF (daf_is_not_blank(tab_info->updt_val_list))
      SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
     ENDIF
     SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
      v_rdds_where_iu_str,
      " and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " > v_curdate and active_ind = 1 and t1.tier_group_cd = r1.tier_group_cd)",
      " where t1.tier_group_cd in ( select tier_group_cd from ",tab_info->tab_$r,
      " where ",v_rdds_where_iu_str," and active_ind = 1 and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate)",
      " and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name," <= v_curdate and ",tab_info->
      cols[tab_info->end_eff_col_ndx].column_name," >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate "," and active_ind = 1 ")
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
   ELSEIF ((tab_info->merge_delete_ind=0))
    IF ((tab_info->versioning_ind=1)
     AND  NOT ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7"))))
     IF ((tab_info->table_name="WORKING_VIEW"))
      SET v_update_str = concat("update into ",tab_info->table_name," t1 set (CURRENT_WORKING_VIEW ")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      SET v_update_str = concat(v_update_str,") (select nullval(",tab_info->pk_col_list,",0.0) ")
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," R where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
         ELSE
          SET v_update_str = concat(v_update_str," r.",tab_info->cols[drcd_col_cnt].column_name,
           " = t1.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," AND (R.ACTIVE_IND = 1 OR (r.active_ind = 0 and r.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name," <= v_curdate and r.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",'select "x" from ',tab_info->tab_$r," r2 where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r2.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","r."))
         ELSE
          SET v_update_str = concat(v_update_str," r2.",tab_info->cols[drcd_col_cnt].column_name,
           " = r.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," and "," r2.active_ind = 1 ",
       "and r2.rdds_delete_ind = 0 and r2.rdds_context_name =v_context_to_set and r2.rdds_source_env_id =v_source_env_id ",
       "and r2.rdds_status_flag < 9000))) AND ",
       "r.rdds_delete_ind = 0 and r.rdds_context_name =v_context_to_set and r.rdds_source_env_id =v_source_env_id ",
       "and r.rdds_status_flag < 9000"," and rowid=rbr_rowid)")
      SET v_update_str = concat(v_update_str," where list(",tab_info->ui_col_list,") in (select ",
       tab_info->ui_col_list,
       " from ",tab_info->tab_$r," r3 where "," (R3.ACTIVE_IND = 1 OR (r3.active_ind = 0 and r3.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       " <= v_curdate and r3.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",'select "x" from ',tab_info->tab_$r,
       " r4 where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r4.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","r3."))
         ELSE
          SET v_update_str = concat(v_update_str," r4.",tab_info->cols[drcd_col_cnt].column_name,
           " = r3.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," and "," r4.active_ind = 1 ",
       "and r4.rdds_delete_ind = 0 and r4.rdds_context_name =v_context_to_set and r4.rdds_source_env_id =v_source_env_id ",
       "and r4.rdds_status_flag < 9000))) AND ",
       "r3.rdds_delete_ind = 0 and r3.rdds_context_name =v_context_to_set and r3.rdds_source_env_id =v_source_env_id ",
       "and r3.rdds_status_flag < 9000"," and rowid=rbr_rowid)")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
     SET v_vers_where_str = " and active_ind = 1 "
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind=0 ")
     IF ((tab_info->end_eff_col_ndx > 0))
      SET v_update_str = concat(v_update_str,", ",tab_info->cols[tab_info->end_eff_col_ndx].
       column_name," = v_curdate ")
     ENDIF
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where list (",tab_info->ui_col_list,") in (select ",
      tab_info->ui_col_list,
      " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and active_ind = 1")
     IF (v_mvr_ind=1)
      SET v_update_str = concat(v_update_str," and ",v_mover_string)
     ENDIF
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     IF ((tab_info->end_eff_col_ndx > 0)
      AND (tab_info->beg_eff_col_ndx > 0))
      SET cms_eff_str = concat(" and active_ind = 0 and ",tab_info->cols[tab_info->beg_eff_col_ndx].
       column_name," <= v_curdate and ",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",
       'select "X" from ',tab_info->tab_$r," r2 where r2.active_ind = 1 ")
      FOR (col_ndx = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[col_ndx].ident_ind=1))
         IF ((tab_info->cols[col_ndx].nullable="N"))
          SET cms_eff_str = concat(cms_eff_str," and r2.",tab_info->cols[col_ndx].column_name,
           " = r1.",tab_info->cols[col_ndx].column_name)
         ELSE
          SET cms_eff_str = concat(cms_eff_str," and (r2.",tab_info->cols[col_ndx].column_name,
           " = r1.",tab_info->cols[col_ndx].column_name,
           " or (r2.",tab_info->cols[col_ndx].column_name," is null and r1.",tab_info->cols[col_ndx].
           column_name," is null)) ")
         ENDIF
        ENDIF
      ENDFOR
      SET cms_eff_str = concat(cms_eff_str," and r2.rdds_status_flag < 9000)")
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->
       upd_col_list,") (select ",
       tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str,
       cms_eff_str," and ",tab_info->pk_match_str,") ","where list(",
       tab_info->pk_col_list,") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r,
       " r_A where ",v_rdds_where_iu_str,replace(cms_eff_str,"r1.","r_A.",0),")")
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
    ELSE
     SET v_vers_where_str = " "
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG6", "ALG7")))
     IF ((((tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
      AND (tab_info->end_eff_col_ndx > 0)
      AND (tab_info->beg_eff_col_ndx > 0))) )
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (t1.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,", t1.active_ind")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      IF ((tab_info->user_dt_tm_ind=1))
       SET v_update_str = concat(v_update_str,") (select evaluate(least(t1.",tab_info->cols[tab_info
        ->end_eff_col_ndx].column_name,", v_curdate),v_curdate, r1.",tab_info->cols[tab_info->
        end_eff_col_ndx].column_name,
        ", t1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
        "), evaluate(r1.active_ind, 0, r1.active_ind, t1.active_Ind) ")
      ELSE
       SET v_update_str = concat(v_update_str,") (select evaluate(least(t1.",tab_info->cols[tab_info
        ->end_eff_col_ndx].column_name,", v_curdate),v_curdate, v_curdate, t1.",tab_info->cols[
        tab_info->end_eff_col_ndx].column_name,
        "), evaluate(r1.active_ind, 0, r1.active_ind, t1.active_Ind) ")
      ENDIF
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
       v_rdds_where_iu_str,
       " and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,"<= v_curdate")
      IF ((tab_info->version_cdf="ALG6"))
       FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
         IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
          IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
           SET v_update_str = concat(v_update_str," and ",tab_info->cols[drcd_col_cnt].upd_val_str,
            " = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
          ELSE
           SET v_update_str = concat(v_update_str," and r1.",tab_info->cols[drcd_col_cnt].column_name,
            " = t1.",tab_info->cols[drcd_col_cnt].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drcd_temp_col_str = tab_info->ui_col_list
      ELSE
       SET v_update_str = concat(v_update_str," and ",tab_info->grouper_match_str)
       SET drcd_temp_col_str = tab_info->grouper_col_list
      ENDIF
      SET v_update_str = concat(v_update_str,") where list(",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," r_A where ",v_rdds_where_iu_str," and ",
       tab_info->cols[tab_info->end_eff_col_ndx].column_name," <= v_curdate) and t1.",tab_info->cols[
       tab_info->beg_eff_col_ndx].column_name," <= v_curdate and t1.",tab_info->cols[tab_info->
       end_eff_col_ndx].column_name,
       " >= v_curdate and t1.active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (t1.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,", t1.active_ind")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      IF ((tab_info->user_dt_tm_ind=1))
       SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
        cols[tab_info->end_eff_col_ndx].column_name,", datetimeadd(r1.",tab_info->cols[tab_info->
        beg_eff_col_ndx].column_name,
        ", (-1/86400))), r1.active_ind")
      ELSE
       IF ((tab_info->static_active_ind=1)
        AND (tab_info->version_cdf="ALG6"))
        SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
         cols[tab_info->end_eff_col_ndx].column_name,", v_curdate), t1.active_ind ")
       ELSE
        SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
         cols[tab_info->end_eff_col_ndx].column_name,", v_curdate), 0 ")
       ENDIF
      ENDIF
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
       v_rdds_where_iu_str,
       " and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,">= v_curdate")
      SET drcd_temp_match_str = " "
      IF ((tab_info->version_cdf="ALG6"))
       FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
         IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
          IF (daf_is_blank(drcd_temp_match_str))
           IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
            SET drcd_temp_match_str = concat(" and ",tab_info->cols[drcd_col_cnt].upd_val_str," = ",
             replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
           ELSE
            SET drcd_temp_match_str = concat(" and r1.",tab_info->cols[drcd_col_cnt].column_name,
             " = t1.",tab_info->cols[drcd_col_cnt].column_name)
           ENDIF
          ELSE
           IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
            SET drcd_temp_match_str = concat(drcd_temp_match_str," and ",tab_info->cols[drcd_col_cnt]
             .upd_val_str," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
           ELSE
            SET drcd_temp_match_str = concat(drcd_temp_match_str," and r1.",tab_info->cols[
             drcd_col_cnt].column_name," = t1.",tab_info->cols[drcd_col_cnt].column_name)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET drcd_temp_col_str = tab_info->ui_col_list
      ELSE
       SET drcd_temp_match_str = concat(" and ",tab_info->grouper_match_str)
       SET drcd_temp_col_str = tab_info->grouper_col_list
      ENDIF
      SET v_update_str = concat(v_update_str,drcd_temp_match_str," and r1.",tab_info->cols[tab_info->
       beg_eff_col_ndx].column_name," in(select min(r2.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,") from ",tab_info->tab_$r," r2 ",
       " where ",
       v_rdds_where_iu_str," and r2.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       ">= v_curdate ",replace(drcd_temp_match_str,"t1.","r2.",0),
       ")")
      SET v_update_str = concat(v_update_str,") where list(",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," r_A where ",v_rdds_where_iu_str," and ",
       tab_info->cols[tab_info->end_eff_col_ndx].column_name," >= v_curdate) and t1.",tab_info->cols[
       tab_info->beg_eff_col_ndx].column_name," <= v_curdate and t1.",tab_info->cols[tab_info->
       end_eff_col_ndx].column_name,
       " >= v_curdate and t1.active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_update_str = concat("update from ",tab_info->table_name," set active_ind = 0 ")
      IF (daf_is_not_blank(tab_info->updt_upd_val_str))
       SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
      ENDIF
      SET v_update_str = concat(v_update_str," where list (",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and ",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name," >= v_curdate and active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and r1.","active_ind = 1")
     ELSEIF ((tab_info->version_cdf="ALG7"))
      SET v_vers_where_str = " and active_ind = 1 "
      SET v_update_str = concat("update into ",tab_info->table_name," set active_ind=0 ")
      IF (daf_is_not_blank(tab_info->updt_upd_val_str))
       SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
      ENDIF
      SET v_update_str = concat(v_update_str," where list (",tab_info->grouper_col_list,
       ") in (select ",tab_info->grouper_col_list,
       " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     FOR (drcd_col_loop = 1 TO size(tab_info->cols,5))
       FOR (drcd_circ_loop = 1 TO tab_info->cols[drcd_col_loop].circ_cnt)
         IF ((other_info->table_name != tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].
         circ_table_name))
          CALL init_rs_data(other_info)
          CALL get_meta_data(tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
           other_info)
         ENDIF
         SET stat = alterlist(drcd_orig_str->cols,size(other_info->cols,5))
         FOR (drcd_circ_col_loop = 1 TO size(other_info->cols,5))
           IF ((other_info->cols[drcd_circ_col_loop].pk_ind=1))
            SET tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_pk_col_name = other_info
            ->cols[drcd_circ_col_loop].column_name
           ENDIF
           SET drcd_orig_str->cols[drcd_circ_col_loop].str = other_info->cols[drcd_circ_col_loop].
           ins_val_str
           IF ((other_info->cols[drcd_circ_col_loop].column_name=tab_info->cols[drcd_col_loop].
           circ_qual[drcd_circ_loop].circ_pk_col_name))
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,other_info->cols[drcd_circ_col_loop].column_name,
             tab_info->cols[drcd_col_loop].column_name,0)
           ELSEIF ((other_info->cols[drcd_circ_col_loop].column_name=tab_info->cols[drcd_col_loop].
           circ_qual[drcd_circ_loop].circ_fk_col_name))
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,other_info->cols[drcd_circ_col_loop].column_name,
             tab_info->cols[tab_info->pk_col_ndx].column_name,0)
           ELSE
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,"r1.","cc.",0)
           ENDIF
         ENDFOR
         SET other_info->all_ins_val_str = " "
         SET other_info->pk_col_list = " "
         SET other_info->ui_col_list = " "
         SET other_info->upd_col_list = " "
         SET other_info->upd_val_list = " "
         SET other_info->all_upd_val_str = " "
         SET other_info->col_list = " "
         SET other_info->updt_upd_val_str = " "
         SET other_info->updt_col_list = " "
         SET other_info->updt_val_list = " "
         SET other_info->grouper_col_list = " "
         CALL create_merge_strs(other_info)
         FOR (drcd_circ_col_loop = 1 TO size(other_info->cols,5))
           SET other_info->cols[drcd_circ_col_loop].ins_val_str = drcd_orig_str->cols[
           drcd_circ_col_loop].str
         ENDFOR
         SET v_insert_str = concat("insert into ",tab_info->cols[drcd_col_loop].circ_qual[
          drcd_circ_loop].circ_table_name," t1 (",other_info->col_list,") (select ",
          other_info->all_ins_val_str," from ",tab_info->tab_$r," r1, ",tab_info->table_name,
          " t1_A, ",other_info->table_name," cc where ",replace(v_rdds_where_iu_str,"rowid=",
           "r1.rowid="))
         SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
          " != r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name," and t1_A.",
          tab_info->cols[tab_info->pk_col_ndx].column_name," = r1.",tab_info->cols[tab_info->
          prev_pk_col_ndx].column_name)
         SET v_vers_where_str = concat(v_vers_where_str,' and not exists (select "x" from ',tab_info
          ->table_name," t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),
          ")")
         IF (daf_is_not_blank(tab_info->cols[drcd_col_loop].self_entity_name))
          SET v_vers_where_str = concat(v_vers_where_str," and evaluate_pe_name('",tab_info->
           table_name,"', '",tab_info->cols[drcd_col_loop].column_name,
           "', '",tab_info->cols[drcd_col_loop].self_entity_name,"', t1_A.",tab_info->cols[
           drcd_col_loop].self_entity_name,") = '",
           other_info->table_name,"'")
         ENDIF
         SET v_vers_where_str = concat(v_vers_where_str," and cc.",other_info->cols[other_info->
          pk_col_ndx].column_name," = t1_A.",tab_info->cols[drcd_col_loop].column_name,
          " and cc.",other_info->cols[other_info->pk_col_ndx].column_name," > 0 and not exists (",
          "select 'x' from ",other_info->table_name,
          " l_A where l_A.",other_info->cols[other_info->pk_col_ndx].column_name," = r1.",tab_info->
          cols[drcd_col_loop].column_name,"))")
         SET v_insert_str = concat(v_insert_str,v_vers_where_str)
         SET v_vers_where_str = " "
         CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
          o_rs_stmts)
         SET drcd_circ_long_pos = 0
         SET drcd_circ_long_pos = locateval(drcd_circ_col_idx,1,size(other_info->cols,5),"LONG",
          other_info->cols[drcd_circ_col_idx].data_type)
         IF (drcd_circ_long_pos=0)
          SET drcd_circ_long_pos = locateval(drcd_circ_col_idx,1,size(other_info->cols,5),"LONG RAW",
           other_info->cols[drcd_circ_col_idx].data_type)
         ENDIF
         IF (drcd_circ_long_pos > 0)
          SET tab_info->long_call = concat("call move_circ_long(^",tab_info->table_name,"^ , ^",
           tab_info->tab_$r,"^ , ^",
           tab_info->cols[tab_info->pk_col_ndx].column_name,"^ , <BrEaK>^",tab_info->cols[tab_info->
           prev_pk_col_ndx].column_name,"^ ,^",tab_info->cols[drcd_col_loop].column_name,
           "^ , ^",tab_info->cols[drcd_col_loop].self_entity_name,"^ , <BrEaK>^",other_info->
           table_name,"^ , ^",
           other_info->cols[other_info->pk_col_ndx].column_name,"^ , ^",tab_info->cols[drcd_col_loop]
           .circ_qual[drcd_circ_loop].circ_fk_col_name,"^ , <BrEaK>^",other_info->cols[
           drcd_circ_long_pos].column_name,
           "^ , <BrEaK> v_source_env_id, -1*v_stmt_num)")
         ENDIF
         IF (daf_is_not_blank(tab_info->long_call))
          CALL add_stmt(tab_info->long_call,0,1,1,s_stmt_cnt,
           o_rs_stmts)
         ENDIF
         SET tab_info->long_call = ""
       ENDFOR
     ENDFOR
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("t1_a.",tab_info->cols[
      tab_info->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = "v_curdate"
     SET stat = alterlist(drcd_orig_str->cols,size(tab_info->cols,5))
     FOR (i = 1 TO size(tab_info->cols,5))
      SET drcd_orig_str->cols[i].str = tab_info->cols[i].ins_val_str
      IF ( NOT (i IN (tab_info->prev_pk_col_ndx, tab_info->pk_col_ndx)))
       SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"r1.","t1_A.",0)
      ENDIF
     ENDFOR
     FOR (drcd_col_loop = 1 TO size(tab_info->cols,5))
       FOR (drcd_circ_loop = 1 TO tab_info->cols[drcd_col_loop].circ_cnt)
         IF (daf_is_not_blank(tab_info->cols[drcd_col_loop].self_entity_name))
          IF (drcd_circ_loop=1)
           SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
            ins_val_str,concat("t1_A.",tab_info->cols[drcd_col_loop].column_name),concat(
             "evaluate(nullval(t1_A.",tab_info->cols[drcd_col_loop].column_name,", 0), 0, t1_A.",
             tab_info->cols[drcd_col_loop].column_name,", <NeXt EvAl>)"),0)
           SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
            ins_val_str,"<NeXt EvAl>)",concat("evaluate(evaluate_pe_name('",tab_info->table_name,
             "', '",tab_info->cols[drcd_col_loop].column_name,"', '",
             tab_info->cols[drcd_col_loop].self_entity_name,"', t1_A.",tab_info->cols[drcd_col_loop].
             self_entity_name,"), '",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].
             circ_table_name,
             "', r1.",tab_info->cols[drcd_col_loop].column_name,", "),0)
          ELSEIF ((drcd_circ_loop < tab_info->cols[drcd_col_loop].circ_cnt))
           SET tab_info->cols[drcd_col_loop].ins_val_str = concat(tab_info->cols[drcd_col_loop].
            ins_val_str,"'",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
            "', r1.",tab_info->cols[drcd_col_loop].column_name,
            ", ")
          ELSE
           SET tab_info->cols[drcd_col_loop].ins_val_str = concat(tab_info->cols[drcd_col_loop].
            ins_val_str,"'",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
            "', r1.",tab_info->cols[drcd_col_loop].column_name,
            ", t1_A.",tab_info->cols[drcd_col_loop].column_name,"))")
          ENDIF
         ELSE
          SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
           ins_val_str,concat("t1_A.",tab_info->cols[drcd_col_loop].column_name),concat(
            "evaluate(nullval(t1_A.",tab_info->cols[drcd_col_loop].column_name,",0), 0, t1_A.",
            tab_info->cols[drcd_col_loop].column_name,", r1.",
            tab_info->cols[drcd_col_loop].column_name,")"),0)
         ENDIF
       ENDFOR
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " != r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name," and t1_A.",
      tab_info->cols[tab_info->pk_col_ndx].column_name," = r1.",tab_info->cols[tab_info->
      prev_pk_col_ndx].column_name)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1, ",tab_info->table_name,
      " t1_A where ",replace(v_rdds_where_iu_str,"rowid=","r1.rowid="),v_vers_where_str,
      ' and not exists (select "x" from ',tab_info->table_name,
      " t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),"))")
     SET v_vers_where_str = " "
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     FOR (i = 1 TO size(tab_info->cols,5))
       SET tab_info->cols[i].ins_val_str = drcd_orig_str->cols[i].str
     ENDFOR
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = "v_curdate"
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->end_eff_col_ndx].column_name)
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " = r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
    ENDIF
    IF ((((tab_info->user_dt_tm_ind=0)
     AND (tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
     AND (tab_info->end_eff_col_ndx > 0)
     AND (tab_info->beg_eff_col_ndx > 0))) )
     SET drcd_temp_set_stmt = tab_info->upd_val_list
     SET drcd_temp_set_stmt = replace(drcd_temp_set_stmt,tab_info->cols[tab_info->beg_eff_col_ndx].
      upd_val_str,concat("evaluate(least(r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ",v_curdate), v_curdate, r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,", t1.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,")"),0)
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      drcd_temp_set_stmt," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ELSE
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ENDIF
    SET v_update_str = concat(v_update_str,v_vers_where_str," and ",tab_info->pk_match_str,")",
     " where list(",tab_info->pk_col_list,") in (select",tab_info->pk_col_list," from ",
     tab_info->tab_$r," r_A where ",v_rdds_where_iu_str,replace(v_vers_where_str,"r1.","r_A.",0),
     v_upd1_sect2_dml,
     ")")
    CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = " "
    ENDIF
    IF ((tab_info->table_name="SA_REF_ACTION"))
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,")",
      " (select ",tab_info->all_ins_val_str," from ",tab_info->tab_$r,
      " r1 where r1.action_description = <BrEaK>'RDDS FILL ROW' and ",
      v_rdds_where_iu_str,' and not exists(select "x" from ',tab_info->table_name," t_A where ",
      replace(tab_info->pk_match_str,"t1.","t_A.",0),
      "))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->table_name="PRSNL"))
     SET v_insert_str = concat(" insert into dm_chg_log t1 ",
      " (log_type, log_id, table_name, target_env_id, pk_where, chg_dt_tm) ",
      " (select 'PRSSEC', seq(dm_clinical_seq, nextval), 'PRSNL', ",trim(cnvtstring(o_rs_stmts->
        target_env_id,20)),
      ".0, concat(r1.username,'&', r1.name_full_formatted), cnvtdatetime(curdate, curtime3) from ",
      tab_info->tab_$r," r1 where trim(r1.username) > ' ' and ",v_rdds_where_iu_str,v_vers_where_str,
      " and not exists (select 'x' from ",
      tab_info->table_name," t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " = r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
    ENDIF
    IF ((((tab_info->user_dt_tm_ind=0)
     AND (tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
     AND (tab_info->end_eff_col_ndx > 0)
     AND (tab_info->beg_eff_col_ndx > 0))) )
     SET drcd_temp_set_stmt = tab_info->all_ins_val_str
     SET drcd_temp_set_stmt = replace(drcd_temp_set_stmt,tab_info->cols[tab_info->beg_eff_col_ndx].
      ins_val_str,concat("evaluate(least(r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ",v_curdate), v_curdate, r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ", v_curdate)"),0)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      drcd_temp_set_stmt," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ELSE
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ENDIF
    SET v_insert_str = concat(v_insert_str,v_vers_where_str,v_ins1_sect1_dml,
     ' and not exists (select "x" from ',tab_info->table_name,
     " t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),")")
    IF ((tab_info->table_name IN ("OMF_PV_SECURITY_FILTER", "OMF_PV_COL_SEC")))
     SET v_insert_str = concat(v_insert_str,
      ' and exists (select "x" from OMF_GRID og, OMF_GRID_COLUMN ogc, OMF_VO_TYPE ovt, OMF_VO_TYPE_DISPLAY ovtd,',
      " OMF_VO_INDICATOR_GROUP ovig, OMF_INDICATOR oil "," where "," og.grid_cd = r1.grid_cd and ",
      " og.active_ind = 1 and "," ogc.grid_cd = og.grid_cd and ",
      " ovt.vo_type_cd = ogc.grid_column_cd and "," ovtd.vo_type_cd = ovt.vo_type_cd and ",
      " ovig.parent_indicator_cd = ovt.vo_indicator_cd and ",
      " ovig.vo_display_seq = ovtd.vo_display_seq and ",
      " oil.indicator_cd = ovig.child_indicator_cd and "," oil.indicator_cd = r1.indicator_cd) ",
      ' or exists (select "x" from OMF_GRID og, OMF_GRID_COLUMN ogc, OMF_INDICATOR oil '," where ",
      " og.grid_cd = r1.grid_cd and "," og.active_ind = 1 and "," ogc.grid_cd = og.grid_cd and ",
      " oil.indicator_cd = ogc.grid_column_cd and "," oil.indicator_cd = r1.indicator_cd)")
    ENDIF
    SET v_insert_str = concat(v_insert_str,")")
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7")))
     SET v_vers_where_str = " "
    ENDIF
    CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    IF ((tab_info->versioning_ind=1)
     AND  NOT ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7")))
     AND (tab_info->beg_eff_col_ndx > 0)
     AND (tab_info->end_eff_col_ndx > 0))
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str,
      cms_eff_str,' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(
       tab_info->pk_match_str,"t1.","t_A.",0),
      ")")
     SET v_insert_str = concat(v_insert_str,")")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->version_cdf="ALG5"))
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = "v_curdate"
     FOR (i = 1 TO size(tab_info->cols,5))
       IF ((i != tab_info->pk_col_ndx))
        SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"r1.","t2.",0)
       ELSE
        SET tab_info->cols[i].ins_val_str = concat("seq(",tab_info->cols[i].sequence_name,",nextval)"
         )
       ENDIF
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
     SET v_vers_where_str = concat(" t2.",tab_info->cols[tab_info->pk_col_ndx].column_name," = t2.",
      tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
     IF (v_mvr_ind=1)
      SET v_mover_alg5_string = concat(" and ",v_mover_string)
     ELSE
      SET v_mover_alg5_string = " "
     ENDIF
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->table_name," t2 "," where ",
      v_vers_where_str,v_mover_alg5_string,' and exists(select "x" from ',tab_info->tab_$r,
      " r1 where ",
      replace(tab_info->grouper_match_str,"t1.","t2.",0)," and ",v_rdds_where_iu_str," and r1.",
      tab_info->cols[tab_info->pk_col_ndx].column_name,
      " in(select min(r2.",tab_info->cols[tab_info->pk_col_ndx].column_name,") from ",tab_info->
      tab_$r," r2 ",
      " where r2.rdds_delete_ind = 0 and r2.rdds_status_flag < 9000 and ",replace(tab_info->
       grouper_match_str,"t1.","r2.",0),')) and not exists (select "x" from ',tab_info->tab_$r,
      " R_A where ",
      replace(replace(tab_info->pk_match_str,"t1.","R_A.",0),"r1.","t2.",0),
      ") and t2.active_ind = 1 )")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," t1 "," set t1.active_ind=0, t1.",
      tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " = v_curdate ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where t1.",tab_info->cols[tab_info->pk_col_ndx].
      column_name," = t1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name,
      " and exists (select 'x' from ",tab_info->tab_$r," r1 where ",tab_info->grouper_match_str,")",
      " and not exists (select 'x' from ",tab_info->tab_$r," r2 where t1.",tab_info->cols[tab_info->
      pk_col_ndx].column_name," = r2.",
      tab_info->cols[tab_info->pk_col_ndx].column_name,")"," and t1.active_ind = 1")
     IF (v_mvr_ind=1)
      SET v_update_str = concat(v_update_str," and ",v_mover_string)
     ENDIF
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_vers_where_str = " "
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->end_eff_col_ndx].column_name)
     FOR (i = 1 TO size(tab_info->cols,5))
       IF ((i != tab_info->pk_col_ndx))
        SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"t2.","r1.",0)
       ELSE
        SET tab_info->cols[i].ins_val_str = concat("r1.",tab_info->cols[i].column_name)
       ENDIF
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
    ENDIF
   ELSEIF ((tab_info->merge_delete_ind=1))
    SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
     md_col_list,") in (select ",
     tab_info->md_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_str)
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_delete_str = concat(v_delete_str," and 1 = 2 )")
    ELSE
     SET v_delete_str = concat(v_delete_str," )")
    ENDIF
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_delete_str = concat(v_delete_str," and not (",tab_info->default_row_str," )")
    ENDIF
    IF (v_mvr_ind=1)
     SET v_delete_str = concat(v_delete_str," and ",v_mover_string)
    ENDIF
    CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
     pk_col_list,") in (select ",
     tab_info->pk_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,
     ") ")
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_delete_str = concat(v_delete_str," and not (",tab_info->default_row_str," )")
    ENDIF
    IF (v_mvr_ind=1)
     SET v_delete_str = concat(v_delete_str," and ",v_mover_string)
    ENDIF
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_delete_str = concat(v_delete_str," and 1 = 2 ")
    ENDIF
    CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,")",
     " (select ",tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",
     v_rdds_where_iu_str)
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_insert_str = concat(v_insert_str," and not (",tab_info->default_row_str,") ")
    ENDIF
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_insert_str = concat(v_insert_str,
      " and r1.EA_USER_ID not in (select ea_user_id from EA_USER_ATTRIBUTE_RELTN)")
    ENDIF
    SET v_insert_str = concat(v_insert_str,")")
    CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
   ENDIF
   IF (daf_is_not_blank(tab_info->long_call))
    CALL add_stmt(tab_info->long_call,0,1,1,s_stmt_cnt,
     o_rs_stmts)
   ENDIF
   FREE RECORD tab_info
 END ;Subroutine
 SUBROUTINE create_merge_strs(i_tab_info)
   FOR (s_col_ndx = 1 TO size(i_tab_info->cols,5))
     IF ((i_tab_info->cols[s_col_ndx].long_ind=0))
      IF ((i_tab_info->cols[s_col_ndx].pk_ind=0))
       SET i_tab_info->upd_col_list = concat(i_tab_info->upd_col_list,", t1.",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->upd_val_list = concat(i_tab_info->upd_val_list,", ",i_tab_info->cols[s_col_ndx
        ].upd_val_str)
       SET i_tab_info->all_upd_val_str = concat(i_tab_info->all_upd_val_str,", t1.",i_tab_info->cols[
        s_col_ndx].column_name," = ",i_tab_info->cols[s_col_ndx].upd_val_str)
       IF ((i_tab_info->table_name="TIER_MATRIX"))
        IF ((s_col_ndx != i_tab_info->beg_eff_col_ndx))
         SET i_tab_info->tm_all_upd_val_str = concat(i_tab_info->tm_all_upd_val_str," , ",i_tab_info
          ->cols[s_col_ndx].ins_val_str)
        ELSE
         SET i_tab_info->tm_all_upd_val_str = concat(i_tab_info->tm_all_upd_val_str,", v_todaymid")
        ENDIF
       ENDIF
      ENDIF
      SET i_tab_info->all_ins_val_str = concat(i_tab_info->all_ins_val_str," , ",i_tab_info->cols[
       s_col_ndx].ins_val_str)
      IF ((i_tab_info->table_name="TIER_MATRIX"))
       IF ((s_col_ndx != i_tab_info->beg_eff_col_ndx))
        SET i_tab_info->tm_all_ins_val_str = concat(i_tab_info->tm_all_ins_val_str," , ",i_tab_info->
         cols[s_col_ndx].ins_val_str)
       ELSE
        SET i_tab_info->tm_all_ins_val_str = concat(i_tab_info->tm_all_ins_val_str,", v_todaymid")
       ENDIF
      ENDIF
      SET i_tab_info->col_list = concat(i_tab_info->col_list,", t1.",i_tab_info->cols[s_col_ndx].
       column_name)
      IF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_CNT"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = ",i_tab_info->cols[s_col_ndx].column_name,
        "+1")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", t1.",i_tab_info->cols[
        s_col_ndx].column_name,"+1")
      ELSEIF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_DT_TM"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = v_curdate")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", v_curdate")
      ELSEIF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_TASK"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = 4310001")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", 4310001")
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].md_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].pk_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].ident_ind=1)
       AND daf_is_blank(i_tab_info->ui_col_list_ovr))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].grouper_col_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", ",i_tab_info->cols[
         s_col_ndx].column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
           i_tab_info->cols[s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
           i_tab_info->cols[s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,
           ", nullval(cnvtreal(",i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
          i_tab_info->cols[s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
          i_tab_info->cols[s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET i_tab_info->long_pk_str = concat("set v_long_pk_str = ^",i_tab_info->pk_long_str,"^ go")
      SET i_tab_info->long_call = concat("call move_long(^",tab_info->tab_$r,"^ , ^",i_tab_info->
       table_name,"^ , ^",
       i_tab_info->cols[s_col_ndx].column_name,"^ , <BrEaK>^",i_tab_info->pk_long_str,
       "^ , v_source_env_id, -1*v_stmt_num)")
     ENDIF
   ENDFOR
   SET i_tab_info->upd_val_list = substring(2,10000,i_tab_info->upd_val_list)
   SET i_tab_info->upd_col_list = substring(2,10000,i_tab_info->upd_col_list)
   SET i_tab_info->all_upd_val_str = substring(2,10000,i_tab_info->all_upd_val_str)
   SET i_tab_info->all_ins_val_str = substring(3,10000,i_tab_info->all_ins_val_str)
   SET i_tab_info->col_list = substring(2,10000,i_tab_info->col_list)
   SET i_tab_info->md_col_list = substring(2,10000,i_tab_info->md_col_list)
   SET i_tab_info->pk_col_list = substring(2,10000,i_tab_info->pk_col_list)
   IF (daf_is_not_blank(i_tab_info->ui_col_list_ovr))
    SET i_tab_info->ui_col_list = i_tab_info->ui_col_list_ovr
   ELSE
    SET i_tab_info->ui_col_list = substring(2,10000,i_tab_info->ui_col_list)
   ENDIF
   SET i_tab_info->grouper_col_list = substring(2,10000,i_tab_info->grouper_col_list)
   IF ((i_tab_info->table_name="TIER_MATRIX"))
    SET i_tab_info->tm_all_ins_val_str = substring(3,10000,i_tab_info->tm_all_ins_val_str)
    SET i_tab_info->tm_all_upd_val_str = substring(3,10000,i_tab_info->tm_all_upd_val_str)
   ENDIF
   SET i_tab_info->updt_upd_val_str = substring(2,10000,i_tab_info->updt_upd_val_str)
   SET i_tab_info->updt_col_list = substring(2,10000,i_tab_info->updt_col_list)
   SET i_tab_info->updt_val_list = substring(2,10000,i_tab_info->updt_val_list)
 END ;Subroutine
 SUBROUTINE cutover_get_and_run_dml(i_table_name,i_source_env_id,i_move_long_ind,i_batch_ind,
  i_tgt_env_id)
   DECLARE s_cgard_return = vc WITH noconstant("S")
   FREE RECORD dml
   RECORD dml(
     1 batch_ind = i2
     1 source_env_id = f8
     1 move_long_ind = i2
     1 table_name = vc
     1 merge_stmt_ind = i2
     1 target_env_id = f8
     1 stmt[*]
       2 str = vc
       2 end_ind = i2
       2 rdb_asis_ind = i2
       2 move_long_str_ind = i2
   )
   SET dml->source_env_id = i_source_env_id
   SET dml->move_long_ind = i_move_long_ind
   SET dml->batch_ind = i_batch_ind
   SET dml->table_name = i_table_name
   SET dml->merge_stmt_ind = 1
   SET dml->target_env_id = i_tgt_env_id
   CALL create_merge_stmts(i_table_name,dml)
   IF (check_error(build("When calling Create_merge_stmts: "))=1)
    SET dm_err->err_ind = 0
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET s_cgard_return = "F"
   ENDIF
   IF (s_cgard_return="S"
    AND size(dml->stmt,5) > 0)
    EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","DML"), replace("ERR_TO_CONTINUE","DRC_CONTINUE")
    IF (check_error(build("When executing DM_RDDS_RUN_STMT: "))=1)
     SET dm_err->err_ind = 0
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET s_cgard_return = "F"
    ENDIF
   ENDIF
   RETURN(s_cgard_return)
 END ;Subroutine
 SUBROUTINE pk_data_default(i_tab_info,i_col_ndx)
  IF ((i_tab_info->cols[i_col_ndx].data_type="DATE"))
   SET drs_date_default = cnvtupper(cnvtalphanum(i_tab_info->cols[i_col_ndx].data_default))
   IF (substring(1,6,drs_date_default)="TODATE"
    AND substring(21,16,drs_date_default)="MMDDYYYYHH24MISS")
    SET i_tab_info->cols[i_col_ndx].data_default = concat("CNVTDATETIME(CNVTDATE(",substring(7,8,
      drs_date_default),"),",substring(15,6,drs_date_default),")")
   ELSEIF (drs_date_default != "SYSDATE")
    SET i_tab_info->cols[i_col_ndx].data_default = "CNVTDATETIME(CNVTDATE(12312100),0)"
   ENDIF
   SET i_tab_info->cols[i_col_ndx].data_default_null_ind = 0
  ELSEIF ((i_tab_info->cols[i_col_ndx].data_type IN ("FLOAT", "NUMBER")))
   SET i_tab_info->cols[i_col_ndx].data_default = replace(i_tab_info->cols[i_col_ndx].data_default,
    "'","",0)
  ELSEIF ((i_tab_info->cols[i_col_ndx].data_type IN ("CHAR", "VARCHAR2", "CLOB", "BLOB", "LONG",
  "LONG RAW", "RAW")))
   SET stat = findstring("'",i_tab_info->cols[i_col_ndx].data_default,1,0)
   IF (stat > 0)
    SET i_tab_info->cols[i_col_ndx].data_default = i_tab_info->cols[i_col_ndx].data_default
   ELSE
    SET i_tab_info->cols[i_col_ndx].data_default = concat("'",i_tab_info->cols[i_col_ndx].
     data_default,"'")
   ENDIF
  ELSE
   SET stat = findstring("'",i_tab_info->cols[i_col_ndx].data_default,1,0)
   IF (stat > 0)
    SET i_tab_info->cols[i_col_ndx].data_default = i_tab_info->cols[i_col_ndx].data_default
   ELSE
    SET i_tab_info->cols[i_col_ndx].data_default = concat("'",i_tab_info->cols[i_col_ndx].
     data_default,"'")
   ENDIF
  ENDIF
  IF ((i_tab_info->cols[i_col_ndx].data_default_null_ind=1))
   CASE (trim(i_tab_info->cols[i_col_ndx].data_type))
    OF "INTEGER":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "BIGINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "SMALLINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "INT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "TINYINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "NUMBER":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "NUMERIC":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "DECIMAL":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "FLOAT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "DOUBLE":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "REAL":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "VARCHAR2":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "VARCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "NVARCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "CHARACTER":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "CHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "NCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE get_meta_data(gmd_table_name,gmd_tab_info)
   DECLARE gmd_query_tab_name = vc WITH protect, noconstant("")
   DECLARE gmd_drcd_index = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_pos = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_num = i4 WITH protect, noconstant(0)
   DECLARE gmd_ovr_ndx = i4 WITH protect, noconstant(0)
   DECLARE gmd_tp_ndx = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_num2 = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_cnt = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_i = i4 WITH protect, noconstant(0)
   DECLARE gmd_curqual = i4 WITH protect, noconstant(0)
   DECLARE gmd_alias_str = vc WITH protect, noconstant("")
   DECLARE gmd_alias_nbr = i4 WITH protect, noconstant(0)
   DECLARE gmd_merge_active_ind = i2
   DECLARE gmd_att_idx = i4 WITH protect, noconstant(0)
   FREE RECORD dml_overrides
   RECORD dml_overrides(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
       2 dml_attribute = vc
       2 dml_value = vc
       2 data_type = vc
   )
   FREE RECORD gmd_attributes
   RECORD gmd_attributes(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
       2 attribute_name = vc
       2 attribute_value = f8
       2 attribute_char = vc
       2 attribute_dt_tm = dq8
   )
   SET gmd_tab_info->table_name = gmd_table_name
   SET gmd_query_tab_name = gmd_table_name
   SET gmd_tab_info->tab_$r = cutover_tab_name(gmd_table_name,"")
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="RDDS ACTIVE_IND MERGE"
    DETAIL
     gmd_merge_active_ind = d.info_number
    WITH nocounter
   ;end select
   IF (check_error("While checking DM_INFO.RDDS ACTIVE_IND MERGE: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE (ut.table_name=gmd_tab_info->tab_$r)
    DETAIL
     gmd_tab_info->r_tab_exists = 1, gmd_query_tab_name = gmd_tab_info->tab_$r
    WITH nocounter
   ;end select
   IF (check_error("While checking for existence of $R table: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    drd.column_name, drd.dml_attribute, drd.dml_value,
    drd.data_type
    FROM dm_refchg_dml drd
    WHERE (drd.table_name=gmd_tab_info->table_name)
    HEAD REPORT
     dml_overrides->cnt = 0
    DETAIL
     IF (drd.dml_attribute="UI_COL_LIST")
      gmd_tab_info->ui_col_list_ovr = drd.dml_value, gmd_tab_info->ui_col_list = drd.dml_value
     ELSEIF (drd.dml_attribute="UI_MATCH_STR")
      gmd_tab_info->ui_match_str_ovr = drd.dml_value, gmd_tab_info->ui_match_str = drd.dml_value
     ELSE
      dml_overrides->cnt = (dml_overrides->cnt+ 1)
      IF (mod(dml_overrides->cnt,10)=1)
       stat = alterlist(dml_overrides->qual,(dml_overrides->cnt+ 9))
      ENDIF
      dml_overrides->qual[dml_overrides->cnt].column_name = drd.column_name, dml_overrides->qual[
      dml_overrides->cnt].dml_attribute = drd.dml_attribute, dml_overrides->qual[dml_overrides->cnt].
      dml_value = drd.dml_value,
      dml_overrides->qual[dml_overrides->cnt].data_type = drd.data_type
     ENDIF
    FOOT REPORT
     stat = alterlist(dml_overrides->qual,dml_overrides->cnt)
    WITH nocounter
   ;end select
   IF (check_error("While gathering dml overrides: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_attribute d
    WHERE (d.table_name=gmd_tab_info->table_name)
    DETAIL
     gmd_attributes->cnt = (gmd_attributes->cnt+ 1), stat = alterlist(gmd_attributes->qual,
      gmd_attributes->cnt), gmd_attributes->qual[gmd_attributes->cnt].column_name = d.column_name,
     gmd_attributes->qual[gmd_attributes->cnt].attribute_name = d.attribute_name, gmd_attributes->
     qual[gmd_attributes->cnt].attribute_value = d.attribute_value, gmd_attributes->qual[
     gmd_attributes->cnt].attribute_char = d.attribute_char,
     gmd_attributes->qual[gmd_attributes->cnt].attribute_dt_tm = d.attribute_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(build("While gathering ATTRIBUTES for the ",gmd_tab_info->table_name," table: "))=
   1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name, dcd.unique_ident_ind,
    dcd.constant_value, dcd.exception_flg, dcd.merge_delete_ind,
    dtd.table_name, dtd.table_suffix, dtd.merge_delete_ind,
    dcd.root_entity_name, dcd.root_entity_attr, dcd.parent_entity_col
    FROM dm_tables_doc_local dtd,
     dm_columns_doc_local dcd
    WHERE (dtd.table_name=gmd_tab_info->table_name)
     AND (dcd.table_name=gmd_tab_info->table_name)
     AND dcd.column_name IN (
    (SELECT
     column_name
     FROM user_tab_cols utc
     WHERE utc.table_name=gmd_query_tab_name
      AND utc.hidden_column="NO"
      AND utc.virtual_column="NO"))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE sqlpassthru("dcd.table_name like di.info_char and dcd.column_name like di.info_name")
      AND di.info_domain="RDDS IGNORE COL LIST:*")))
    HEAD REPORT
     gmd_tab_info->table_name = dtd.table_name, gmd_tab_info->table_suffix = dtd.table_suffix,
     gmd_tab_info->merge_delete_ind = dtd.merge_delete_ind,
     gmd_col_cnt = 0
    DETAIL
     gmd_col_cnt = (gmd_col_cnt+ 1)
     IF (mod(gmd_col_cnt,10)=1)
      stat = alterlist(gmd_tab_info->cols,(gmd_col_cnt+ 10))
     ENDIF
     gmd_tab_info->cols[gmd_col_cnt].column_name = dcd.column_name, gmd_tab_info->cols[gmd_col_cnt].
     exception_flg = dcd.exception_flg, gmd_tab_info->cols[gmd_col_cnt].parent_entity_col = dcd
     .parent_entity_col,
     gmd_tab_info->cols[gmd_col_cnt].upd_val_str = build("r1.",dcd.column_name), gmd_tab_info->cols[
     gmd_col_cnt].ins_val_str = build("r1.",dcd.column_name)
     IF (((dtd.merge_delete_ind=0
      AND dcd.unique_ident_ind=1) OR (dtd.merge_delete_ind=1
      AND dcd.merge_delete_ind=1)) )
      IF (dcd.merge_delete_ind=1)
       gmd_tab_info->cols[gmd_col_cnt].md_ind = 1
      ENDIF
      gmd_tab_info->cols[gmd_col_cnt].ident_ind = 1
     ENDIF
     IF (daf_is_not_blank(dcd.constant_value)
      AND dcd.column_name != "UPDT_ID")
      gmd_tab_info->cols[gmd_col_cnt].upd_val_str = concat("t1.",dcd.column_name)
     ENDIF
     IF (dcd.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
     "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
     "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM"))
      gmd_tab_info->beg_eff_col_ndx = gmd_col_cnt
     ELSEIF (dcd.column_name IN ("END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM",
     "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM"))
      gmd_tab_info->end_eff_col_ndx = gmd_col_cnt
     ELSEIF (dcd.column_name="ACTIVE_IND")
      IF (gmd_merge_active_ind=0
       AND dcd.exception_flg != 8)
       gmd_tab_info->cols[gmd_col_cnt].upd_val_str =
       "evaluate(r1.active_ind, 1, t1.active_ind, r1.active_ind)"
      ENDIF
     ENDIF
     FOR (gmd_att_idx = 1 TO gmd_attributes->cnt)
       IF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="BEG_EFFECTIVE COLUMN_NAME_IND")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->beg_eff_col_ndx = gmd_col_cnt
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="END_EFFECTIVE COLUMN_NAME_IND")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->end_eff_col_ndx = gmd_col_cnt
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].attribute_name="USER GENERATED DATE INDICATOR")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->user_dt_tm_ind = 1
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND dcd.column_name="ACTIVE_IND"
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="STATIC COLUMN VALUE")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->static_active_ind = 1
       ENDIF
     ENDFOR
     gmd_col_pos = locateval(gmd_col_num,1,dml_overrides->cnt,dcd.column_name,dml_overrides->qual[
      gmd_col_num].column_name)
     WHILE (gmd_col_pos > 0)
      IF ((dml_overrides->qual[gmd_col_pos].dml_attribute="INS_VAL_STR"))
       gmd_tab_info->cols[gmd_col_cnt].ins_val_str = dml_overrides->qual[gmd_col_pos].dml_value
      ELSEIF ((dml_overrides->qual[gmd_col_pos].dml_attribute="UPD_VAL_STR"))
       gmd_tab_info->cols[gmd_col_cnt].upd_val_str = dml_overrides->qual[gmd_col_pos].dml_value
      ENDIF
      ,
      IF ((gmd_col_pos < dml_overrides->cnt))
       gmd_col_pos = locateval(gmd_col_num,(gmd_col_pos+ 1),dml_overrides->cnt,dcd.column_name,
        dml_overrides->qual[gmd_col_num].column_name)
      ELSE
       gmd_col_pos = 0
      ENDIF
     ENDWHILE
     gmd_tab_info->cols[gmd_col_cnt].sequence_name = dcd.sequence_name
     IF (dcd.exception_flg=12)
      gmd_tab_info->cols[gmd_col_cnt].grouper_col_ind = 1
     ENDIF
    FOOT  dtd.table_name
     stat = alterlist(gmd_tab_info->cols,gmd_col_cnt)
    WITH nocounter
   ;end select
   IF (check_error(build("While getting column list for the ",gmd_tab_info->table_name," table: "))=1
   )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   FOR (gmd_ovr_ndx = 1 TO dml_overrides->cnt)
     IF (daf_is_blank(dml_overrides->qual[gmd_ovr_ndx].column_name))
      IF ((dml_overrides->qual[gmd_ovr_ndx].data_type="CHAR"))
       CALL parser(concat("set gmd_tab_info->",dml_overrides->qual[gmd_ovr_ndx].dml_attribute," = '",
         dml_overrides->qual[gmd_ovr_ndx].dml_value,"' go "),1)
      ELSEIF ((dml_overrides->qual[gmd_ovr_ndx].data_type="NUMBER"))
       CALL parser(concat("set gmd_tab_info->",dml_overrides->qual[gmd_ovr_ndx].dml_attribute," = ",
         dml_overrides->qual[gmd_ovr_ndx].dml_value," go "),1)
      ELSE
       SET dm_err->emsg = build("****Unrecognized data_type: ",dml_overrides->qual[gmd_ovr_ndx].
        data_type,"****")
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     (dummyt d  WITH seq = size(gmd_tab_info->cols,5))
    PLAN (d)
     JOIN (utc
     WHERE (utc.table_name=gmd_tab_info->table_name)
      AND (utc.column_name=gmd_tab_info->cols[d.seq].column_name))
    DETAIL
     gmd_tab_info->cols[d.seq].data_default = utc.data_default, gmd_tab_info->cols[d.seq].
     data_default_null_ind = nullind(utc.data_default), gmd_tab_info->cols[d.seq].data_type = utc
     .data_type
     IF (utc.data_type IN ("LONG", "LONG RAW", "RAW"))
      gmd_tab_info->cols[d.seq].long_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_CNT"
      AND utc.data_type IN ("NUMBER", "FLOAT"))
      gmd_tab_info->cols[d.seq].upd_val_str = "t1.updt_cnt+1", gmd_tab_info->cols[d.seq].ins_val_str
       = "0"
     ELSEIF (utc.column_name="UPDT_DT_TM"
      AND utc.data_type="DATE")
      gmd_tab_info->cols[d.seq].upd_val_str = "v_curdate", gmd_tab_info->cols[d.seq].ins_val_str =
      "v_curdate"
     ENDIF
     gmd_tab_info->cols[d.seq].nullable = "Y"
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the datatypes for the column list for the:",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dtableattr a,
     dtableattrl l
    PLAN (a
     WHERE (a.table_name=gmd_tab_info->table_name))
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
    DETAIL
     gmd_col_pos = 0, gmd_col_pos = locateval(gmd_tp_ndx,1,size(gmd_tab_info->cols,5),l.attr_name,
      gmd_tab_info->cols[gmd_tp_ndx].column_name)
     IF (gmd_col_pos > 0)
      gmd_tab_info->cols[gmd_col_pos].ccl_type = l.type
     ELSE
      gmd_tab_info->cols[gmd_col_pos].ccl_type = "Z"
     ENDIF
    WITH nocounter
   ;end select
   SET gmd_cms_cnt = 0
   SELECT INTO "NL:"
    FROM dm2_user_notnull_cols unc
    WHERE expand(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),unc.column_name,gmd_tab_info->cols[
     gmd_cms_cnt].column_name)
     AND (unc.table_name=gmd_tab_info->table_name)
    DETAIL
     gmd_cms_cnt = locateval(gmd_cms_num2,1,size(gmd_tab_info->cols,5),unc.column_name,gmd_tab_info->
      cols[gmd_cms_num2].column_name)
     IF (gmd_cms_cnt > 0)
      gmd_tab_info->cols[gmd_cms_cnt].nullable = "N", gmd_cms_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(build("While getting all not nullable columns for the table: ",gmd_tab_info->
     table_name))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET gmd_cms_i = 1
   FOR (gmd_cms_i = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
      IF ((((gmd_tab_info->cols[gmd_cms_i].ins_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
       column_name))) OR ((gmd_tab_info->cols[gmd_cms_i].upd_val_str=concat("r1.",gmd_tab_info->cols[
       gmd_cms_i].column_name)))) )
       SELECT INTO "NL:"
        FROM dm2_user_notnull_cols r1
        WHERE (r1.table_name=gmd_tab_info->tab_$r)
         AND (r1.column_name=gmd_tab_info->cols[gmd_cms_i].column_name)
        WITH nocounter
       ;end select
       SET gmd_curqual = curqual
       IF (check_error(build("While getting all not nullable columns for the table: ",gmd_tab_info->
         tab_$r))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN
       ENDIF
       IF (gmd_curqual=0)
        CALL pk_data_default(gmd_tab_info,gmd_cms_i)
        IF ((gmd_tab_info->cols[gmd_cms_i].ins_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
         column_name)))
         IF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("LONG", "CHAR", "VARCHAR2", "DATE")))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK>",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("BLOB", "RAW", "LONG RAW")))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK> hextoraw( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type="*CLOB"))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK> to_clob( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSE
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ENDIF
        ENDIF
        IF ((gmd_tab_info->cols[gmd_cms_i].upd_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
         column_name)))
         IF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("LONG", "CHAR", "VARCHAR2", "DATE")))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK>",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("BLOB", "RAW", "LONG RAW")))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK> hextoraw( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type="*CLOB"))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK> to_clob( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSE
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((gmd_tab_info->cols[gmd_cms_i].ident_ind=1)
      AND daf_is_blank(gmd_tab_info->ui_match_str_ovr))
      IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
       SET gmd_tab_info->ui_match_str = concat(gmd_tab_info->ui_match_str," and t1.",gmd_tab_info->
        cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name)
      ELSE
       SET gmd_tab_info->ui_match_str = concat(gmd_tab_info->ui_match_str," and (t1.",gmd_tab_info->
        cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name,
        " or (t1.",gmd_tab_info->cols[gmd_cms_i].column_name," is null and r1.",gmd_tab_info->cols[
        gmd_cms_i].column_name," is null))")
      ENDIF
     ENDIF
     IF ((gmd_tab_info->cols[gmd_cms_i].grouper_col_ind=1))
      IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
       SET gmd_tab_info->grouper_match_str = concat(gmd_tab_info->grouper_match_str," and t1.",
        gmd_tab_info->cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name)
      ELSE
       SET gmd_tab_info->grouper_match_str = concat(gmd_tab_info->grouper_match_str," and (t1.",
        gmd_tab_info->cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name,
        " or (t1.",gmd_tab_info->cols[gmd_cms_i].column_name," is null and r1.",gmd_tab_info->cols[
        gmd_cms_i].column_name," is null))")
      ENDIF
     ENDIF
   ENDFOR
   IF (daf_is_blank(gmd_tab_info->ui_match_str_ovr))
    SET gmd_tab_info->ui_match_str = substring(6,10000,gmd_tab_info->ui_match_str)
   ENDIF
   SET gmd_tab_info->grouper_match_str = substring(6,10000,gmd_tab_info->grouper_match_str)
   SET gmd_alias_nbr = 0
   FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_col_pos].exception_flg=9))
      SET gmd_tab_info->exception_flg9_ind = 1
      SET gmd_alias_nbr = (gmd_alias_nbr+ 1)
      SET gmd_alias_str = build("d",gmd_alias_nbr)
      SET gmd_tab_info->cols[gmd_col_pos].ins_val_str = concat("(select nullval(max(",gmd_alias_str,
       ".",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3),")+1,1) from ",
       gmd_tab_info->table_name," ",gmd_alias_str," where ",replace(cnvtlower(gmd_tab_info->
         ui_match_str),"t1.",build(gmd_alias_str,"."),0),
       ")")
      CALL echo(build(gmd_tab_info->table_name,".",gmd_tab_info->cols[gmd_col_pos].column_name,
        ".ins_val_str (for sequence max+1) = ",gmd_tab_info->cols[gmd_col_pos].ins_val_str))
     ENDIF
   ENDFOR
   SET gmd_alias_nbr = 0
   SELECT INTO "nl:"
    FROM dm_refchg_version_r drvr
    WHERE (drvr.child_table=gmd_tab_info->table_name)
    DETAIL
     FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
       IF ((gmd_tab_info->cols[gmd_col_pos].column_name=drvr.child_vers_col))
        gmd_alias_nbr = (gmd_alias_nbr+ 1), gmd_alias_str = build("d",gmd_alias_nbr), gmd_tab_info->
        cols[gmd_col_pos].ins_val_str = concat("(select ",build(gmd_alias_str,"."),trim(drvr
          .parent_vers_col)," from ",trim(drvr.parent_table),
         " ",gmd_alias_str," where ",build(gmd_alias_str,"."),trim(drvr.parent_id_col),
         " = r1.",trim(drvr.child_id_col),")"),
        gmd_tab_info->cols[gmd_col_pos].upd_val_str = gmd_tab_info->cols[gmd_col_pos].ins_val_str
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the version of the parent table(s) of the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=4000220
     AND cv.cdf_meaning="INSERT_ONLY"
     AND (cv.display=gmd_tab_info->table_name)
    DETAIL
     CALL echo(build("Target as Master=",cv.display))
     FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
       gmd_tab_info->cols[gmd_col_pos].upd_val_str = build("t1.",gmd_tab_info->cols[gmd_col_pos].
        column_name)
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(build("While checking for the INSERT ONLY code_value row for the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    ucc.column_name
    FROM user_constraints uc,
     user_cons_columns ucc
    WHERE (uc.table_name=gmd_tab_info->table_name)
     AND uc.constraint_type="P"
     AND uc.constraint_name=ucc.constraint_name
     AND uc.table_name=ucc.table_name
     AND  NOT (uc.table_name IN (
    (SELECT
     utc.table_name
     FROM user_tab_cols utc
     WHERE utc.table_name=ucc.table_name
      AND utc.column_name=ucc.column_name
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char")))
     )) )) )))
    DETAIL
     gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),ucc
      .column_name,gmd_tab_info->cols[gmd_drcd_index].column_name)
     IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
      dm_err->emsg = build("****Column not found in table: ",ucc.column_name,"****"), dm_err->err_ind
       = 1
     ELSE
      gmd_tab_info->cols[gmd_col_pos].pk_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
       pk_match_str," and t1.",trim(ucc.column_name,3)," = r1.",trim(ucc.column_name,3)),
      gmd_tab_info->pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(ucc.column_name,3),
       "!= r1.",trim(ucc.column_name,3)),
      CALL pk_data_default(tab_info,gmd_col_pos), gmd_tab_info->default_row_str = concat(gmd_tab_info
       ->default_row_str," and ",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3)," = ",trim(
        gmd_tab_info->cols[gmd_col_pos].data_default,3)), gmd_tab_info->pk_long_str = concat(
       gmd_tab_info->pk_long_str,'," and ',trim(ucc.column_name,3),' = ",')
      IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
      "BLOB")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(ucc.column_name,
         3),',^"^)')
      ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(ucc.column_name,3),
        ")")
      ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
        '"cnvtdatetime(cnvtdate(",concat(format(',trim(ucc.column_name,3),^, "MMDDYYYY"),',',format(^,
        trim(ucc.column_name,3),
        ', "HHMMSS")),")"')
      ENDIF
     ENDIF
    FOOT REPORT
     gmd_tab_info->default_row_str = substring(6,10000,gmd_tab_info->default_row_str), gmd_tab_info->
     pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->pk_diff_str =
     substring(5,10000,gmd_tab_info->pk_diff_str),
     gmd_tab_info->pk_long_str = concat('concat("',trim(substring(8,10000,gmd_tab_info->pk_long_str)),
      ")")
    WITH nocounter
   ;end select
   IF (check_error(concat("While getting the PK information for the ",gmd_tab_info->table_name,
     " table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     di.info_char
     FROM dm_info di
     WHERE di.info_domain=patstring(concat("RDDS PK OVERRIDE:",gmd_tab_info->table_name,"/*"))
      AND (di.info_name=gmd_tab_info->table_name)
     DETAIL
      gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),di
       .info_char,gmd_tab_info->cols[gmd_drcd_index].column_name)
      IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
       dm_err->emsg = build("****Column not found in table: ",di.info_char,"****"), dm_err->err_ind
        = 1
      ELSE
       gmd_tab_info->cols[gmd_col_pos].pk_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
        pk_match_str," and t1.",trim(di.info_char,3)," = r1.",trim(di.info_char,3)), gmd_tab_info->
       pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(di.info_char,3),"!= r1.",trim(di
         .info_char,3)),
       CALL pk_data_default(tab_info,gmd_col_pos), gmd_tab_info->default_row_str = concat(
        gmd_tab_info->default_row_str," and ",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3),
        " = ",trim(gmd_tab_info->cols[gmd_col_pos].data_default,3)), gmd_tab_info->pk_long_str =
       concat(gmd_tab_info->pk_long_str,'," and ',trim(di.info_char,3),' = ",')
       IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
       "BLOB")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(di.info_char,3
          ),',^"^)')
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(di.info_char,3),
         ")")
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
         '"cnvtdatetime(cnvtdate(",concat(format(',trim(di.info_char,3),^, "MMDDYYYY"),',',format(^,
         trim(di.info_char,3),
         ', "HHMMSS")),")"')
       ENDIF
      ENDIF
     FOOT REPORT
      gmd_tab_info->default_row_str = substring(6,10000,gmd_tab_info->default_row_str), gmd_tab_info
      ->pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->pk_diff_str =
      substring(5,10000,gmd_tab_info->pk_diff_str),
      gmd_tab_info->pk_long_str = concat('concat("',trim(substring(8,10000,gmd_tab_info->pk_long_str)
        ),")")
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     dcd.column_name
     FROM dm_columns_doc_local dcd
     WHERE (dcd.table_name=gmd_tab_info->table_name)
      AND dcd.unique_ident_ind=1
     DETAIL
      gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),dcd
       .column_name,gmd_tab_info->cols[gmd_drcd_index].column_name)
      IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
       dm_err->emsg = build("****Column not found in table: ",dcd.column_name,"****"), dm_err->
       err_ind = 1
      ELSE
       gmd_tab_info->cols[gmd_col_pos].pk_ind = 1
       IF ((gmd_tab_info->cols[gmd_col_pos].nullable="N"))
        gmd_tab_info->pk_match_str = concat(gmd_tab_info->pk_match_str," and t1.",trim(dcd
          .column_name,3)," = r1.",trim(dcd.column_name,3))
       ELSE
        gmd_tab_info->nullable_ui_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
         pk_match_str," and (t1.",trim(dcd.column_name,3)," = r1.",trim(dcd.column_name,3),
         " or (t1.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3)," is null))")
       ENDIF
       gmd_tab_info->pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(dcd.column_name,3),
        " != r1.",trim(dcd.column_name,3)), gmd_tab_info->pk_long_str = concat(gmd_tab_info->
        pk_long_str,'," and ',trim(dcd.column_name,3),' = ",')
       IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
       "BLOB")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(dcd
          .column_name,3),',^"^)')
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(dcd.column_name,3),
         ")")
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
         '"cnvtdatetime(cnvtdate(",concat(format(',trim(dcd.column_name,3),
         ^, "MMDDYYYY"),',',format(^,trim(dcd.column_name,3),
         ', "HHMMSS")),")"')
       ENDIF
      ENDIF
     FOOT REPORT
      gmd_tab_info->pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->
      pk_diff_str = substring(5,10000,gmd_tab_info->pk_diff_str), gmd_tab_info->pk_long_str = concat(
       'concat(" ',trim(substring(8,10000,gmd_tab_info->pk_long_str)),")")
     WITH nocounter
    ;end select
    IF (check_error(concat("While getting the PK information for the ",gmd_tab_info->table_name,
      " table: "))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=255351
     AND ((cv.cdf_meaning = null) OR (cv.cdf_meaning != "NONE"))
     AND (cv.display=gmd_tab_info->table_name)
     AND cv.active_ind=1
    DETAIL
     gmd_tab_info->versioning_ind = 1, gmd_tab_info->version_cdf = cv.cdf_meaning
     IF ( NOT (cv.cdf_meaning IN ("ALG2", "ALG5", "ALG6")))
      CALL echo(build(cv.cdf_meaning,": ",cv.display," = ",gmd_tab_info->beg_eff_col_ndx))
      IF ((gmd_tab_info->beg_eff_col_ndx > 0))
       gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].ins_val_str = "v_curdate", gmd_tab_info->
       cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("t1.",gmd_tab_info->cols[gmd_tab_info
        ->beg_eff_col_ndx].column_name)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(build("While selecting the effective date fields for the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET gmd_col_pos = 0
   FOR (gmd_cms_cnt = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_cms_cnt].pk_ind=1))
      SET gmd_col_pos = (gmd_col_pos+ 1)
      SET gmd_tab_info->pk_col_ndx = gmd_cms_cnt
     ENDIF
   ENDFOR
   IF (gmd_col_pos > 1)
    SET gmd_tab_info->pk_col_ndx = 0
   ENDIF
   IF ((gmd_tab_info->version_cdf IN ("ALG2", "ALG5")))
    SET dm_err->eproc = "Gathering Previous PK column for ALG2 or ALG5 table."
    SET gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),1,gmd_tab_info->cols[
     gmd_cms_cnt].pk_ind)
    IF (gmd_cms_cnt > 0)
     SELECT INTO "nl:"
      FROM dm_columns_doc_local d
      WHERE (d.root_entity_name=gmd_tab_info->table_name)
       AND (d.root_entity_attr=gmd_tab_info->cols[gmd_cms_cnt].column_name)
       AND (d.column_name != gmd_tab_info->cols[gmd_cms_cnt].column_name)
       AND d.exception_flg=11
      DETAIL
       gmd_tab_info->prev_pk_col_ndx = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),d
        .column_name,gmd_tab_info->cols[gmd_cms_cnt].column_name)
       IF ((gmd_tab_info->beg_eff_col_ndx > 0))
        gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,
         ",v_curdate), v_curdate, v_curdate, t1.",gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].
         column_name,")")
       ENDIF
       CALL echo(build(gmd_tab_info->version_cdf,":",gmd_tab_info->table_name," = ",gmd_tab_info->
        end_eff_col_ndx))
       IF ((gmd_tab_info->end_eff_col_ndx > 0))
        gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,",v_curdate), r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,", v_curdate, r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,")")
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "nl:"
       FROM dm_columns_doc_local d
       WHERE (d.root_entity_name=gmd_tab_info->table_name)
        AND (d.root_entity_attr=gmd_tab_info->cols[gmd_cms_cnt].column_name)
        AND (d.column_name != gmd_tab_info->cols[gmd_cms_cnt].column_name)
        AND d.column_name="PREV*"
       DETAIL
        gmd_tab_info->prev_pk_col_ndx = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),d
         .column_name,gmd_tab_info->cols[gmd_cms_cnt].column_name)
        IF ((gmd_tab_info->beg_eff_col_ndx > 0))
         gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,
          ",v_curdate), v_curdate, v_curdate, t1.",gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].
          column_name,")")
        ENDIF
        CALL echo(build(gmd_tab_info->version_cdf,":",gmd_tab_info->table_name," = ",gmd_tab_info->
         end_eff_col_ndx))
        IF ((gmd_tab_info->end_eff_col_ndx > 0))
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,",v_curdate), r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,", v_curdate, r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,")")
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET dm_err->err_ind = 1
       CALL disp_msg(build("The table ",gmd_tab_info->table_name,
         " table is not correctly set up for ",gmd_tab_info->version_cdf),dm_err->logfile,1)
       RETURN
      ENDIF
     ENDIF
     IF (check_error(build("While selecting the previous pk column for the ",gmd_tab_info->table_name,
       " table: "))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     SELECT INTO "NL:"
      FROM dm_info di
      WHERE di.info_domain=patstring(concat("RDDS CIRCULAR:",gmd_tab_info->table_name,":*"))
      DETAIL
       IF (di.info_number=2)
        gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),trim(substring((findstring(
            ":",di.info_domain,1,1)+ 1),30,di.info_domain)),gmd_tab_info->cols[gmd_cms_cnt].
         parent_entity_col)
       ELSE
        gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),trim(substring((findstring(
            ":",di.info_domain,1,1)+ 1),30,di.info_domain)),gmd_tab_info->cols[gmd_cms_cnt].
         column_name)
       ENDIF
       IF (gmd_cms_cnt > 0)
        gmd_tab_info->cols[gmd_cms_cnt].circ_cnt = (gmd_tab_info->cols[gmd_cms_cnt].circ_cnt+ 1),
        stat = alterlist(gmd_tab_info->cols[gmd_cms_cnt].circ_qual,gmd_tab_info->cols[gmd_cms_cnt].
         circ_cnt), gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].
        circ_cnt].circ_table_name = substring(1,(findstring(":",di.info_name,1,1) - 1),di.info_name),
        gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].circ_cnt].
        circ_fk_col_name = substring((findstring(":",di.info_name,1,1)+ 1),30,di.info_name),
        gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].circ_cnt].
        circ_entity_col_name = di.info_char
        IF (di.info_number=2)
         gmd_tab_info->cols[gmd_cms_cnt].self_entity_name = substring((findstring(":",di.info_domain,
           1,1)+ 1),30,di.info_domain)
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(build("While selecting the circular references for the ",gmd_tab_info->
       table_name," table: "))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg(build("PK information does not exist for the for the ",gmd_tab_info->table_name,
       " table: "),dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE init_rs_data(ird_info)
   SET ird_info->table_name = ""
   SET ird_info->tab_$r = ""
   SET ird_info->r_tab_exists = 0
   SET ird_info->table_suffix = ""
   SET ird_info->merge_delete_ind = 0
   SET ird_info->versioning_ind = 0
   SET ird_info->version_cdf = ""
   SET ird_info->beg_eff_col_ndx = 0
   SET ird_info->end_eff_col_ndx = 0
   SET ird_info->prev_pk_col_ndx = 0
   SET ird_info->ui_match_str = ""
   SET ird_info->pk_diff_str = ""
   SET ird_info->pk_match_str = ""
   SET ird_info->pk_long_str = ""
   SET ird_info->ui_col_list = ""
   SET ird_info->all_upd_val_str = ""
   SET ird_info->all_ins_val_str = ""
   SET ird_info->tm_all_upd_val_str = ""
   SET ird_info->tm_all_ins_val_str = ""
   SET ird_info->col_list = ""
   SET ird_info->md_col_list = ""
   SET ird_info->pk_col_list = ""
   SET ird_info->default_row_str = ""
   SET ird_info->long_call = ""
   SET ird_info->long_pk_str = ""
   SET ird_info->exception_flg9_ind = 0
   SET ird_info->nullable_ui_ind = 0
   SET ird_info->upd_col_list = ""
   SET ird_info->upd_val_list = ""
   SET ird_info->grouper_col_list = ""
   SET ird_info->grouper_match_str = ""
   SET stat = alterlist(ird_info->cols,0)
   RETURN
 END ;Subroutine
 DECLARE cutover_tab_name(i_normal_tab_name=vc,i_table_suffix=vc) = vc
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE cutover_tab_name(i_normal_tab_name,i_table_suffix)
   DECLARE s_new_tab_name = vc WITH protect
   DECLARE s_tab_suffix = vc WITH protect
   DECLARE s_lv_num = i4 WITH protect
   DECLARE s_lv_pos = i4 WITH protect
   IF (i_table_suffix > " ")
    SET s_tab_suffix = i_table_suffix
    SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
   ELSE
    SET s_lv_pos = locateval(s_lv_num,1,size(table_data->qual,5),i_normal_tab_name,table_data->qual[
     s_lv_num].table_name)
    IF (s_lv_pos > 0)
     SET s_tab_suffix = table_data->qual[s_lv_pos].table_suffix
     SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
    ELSE
     SELECT INTO "nl:"
      FROM dm_rdds_tbl_doc dtd
      WHERE dtd.table_name=i_normal_tab_name
       AND dtd.table_name=dtd.full_table_name
      HEAD REPORT
       stat = alterlist(table_data->qual,(table_data->counter+ 1)), table_data->counter = size(
        table_data->qual,5)
      DETAIL
       table_data->qual[table_data->counter].table_name = dtd.table_name, table_data->qual[table_data
       ->counter].table_suffix = dtd.table_suffix, s_new_tab_name = concat(trim(substring(1,14,
          i_normal_tab_name)),dtd.table_suffix,"$R")
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(s_new_tab_name)
 END ;Subroutine
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
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
 DECLARE dm2_get_env_data(dged_use_admin_ind=i2,dged_environment_id=f8(ref)) = i2
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
 DECLARE dm2_get_dbase_name(dgdn_name_out=vc(ref)) = i2
 SUBROUTINE dm2_get_dbase_name(dgdn_name_out)
   SET dm_err->eproc = "Get database name from currdbname."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (validate(currdbhandle," ")=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (validate(currdbname," ") != " ")
     SET dgdn_name_out = currdbname
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "currdbname is not set."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("dgdn_name_out =",dgdn_name_out))
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 DECLARE dm2ceil(dc_numin) = null
 DECLARE dm2floor(dc_numin) = null
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
 DECLARE val_user_privs(sbr_dummy_param=i2) = i2
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
 DECLARE dm2_findfile(sbr_file_path=vc) = i2
 SUBROUTINE dm2_findfile(sbr_file_path)
   DECLARE dff_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str2 = vc WITH protect, noconstant(" ")
   DECLARE dff_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL dm2_push_dcl(concat('@cer_install:dm2_findfile_os.com "',sbr_file_path,'"'))
    IF ((dm_err->err_ind=1))
     SET dm_err->err_ind = 0
     SET dff_tmp_err_ind = 1
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->errtext="NOT FOUND"))
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," not found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->errtext="FOUND"))
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSEIF (((dff_tmp_err_ind=1) OR ( NOT ((dm_err->errtext IN ("FOUND", "NOT FOUND"))))) )
     SET dm_err->emsg = dm_err->errtext
     SET dm_err->eproc = "Error in DM2_FINDFILE"
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSE
    SET dff_cmd_txt = concat("test -e ",sbr_file_path,";echo $?")
    CALL dm2_push_dcl(dff_cmd_txt)
    SET dm_err->err_ind = 0
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (cnvtint(dm_err->errtext)=0)
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSE
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," not found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_system_defs_init(sbr_sdi_regen_ind=i2) = i2
 SUBROUTINE dm2_system_defs_init(sbr_sdi_regen_ind)
   DECLARE sdi_def_cur_user = vc WITH protect, constant(cnvtupper(currdbuser))
   DECLARE sdi_def1_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def3_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def4_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def5_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue3_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue4_exists_ind = i2 WITH protect, noconstant(0)
   IF (checkdic("USER_VIEWS","T",0)=2)
    SET sdi_def1_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_DBA_TAB_COLUMNS","T",0)=2)
    SET sdi_def2_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_DBA_TAB_COLS","T",0)=2)
    SET sdi_def3_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_USER_TAB_COLS","T",0)=2)
    SET sdi_def4_exists_ind = 1
   ENDIF
   IF (checkdic("PRODUCT_COMPONENT_VERSION","T",0)=2)
    SET sdi_def5_exists_ind = 1
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
    WHERE uv.view_name IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS", "DM2_USER_TAB_COLS")
    DETAIL
     CASE (uv.view_name)
      OF "DM2_DBA_TAB_COLUMNS":
       sdi_vue2_exists_ind = 1
      OF "DM2_DBA_TAB_COLS":
       sdi_vue3_exists_ind = 1
      OF "DM2_USER_TAB_COLS":
       sdi_vue4_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error("Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist."
    )=1)
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
    "from dba_tab_columns dc, dba_synonyms ds" ) asis ( "where ds.table_name = dc.table_name" ) asis
    ( "  and ds.synonym_name != ds.table_name" ) asis ( "  and not exists " ) asis (
    "     (select c.synonym_name, count(*) " ) asis ( "          from dba_synonyms c " ) asis (
    "          where c.synonym_name = ds.synonym_name " ) asis ( "          group by c.synonym_name "
     ) asis ( "          having count(*) > 1) " )
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
   IF (((sdi_vue4_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_vue4_exists_ind=1)
     RDB drop view dm2_user_tab_cols
     END ;Rdb
     IF (check_error("Dropping DM2_USER_TAB_COLS view.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    CALL parser("rdb create view dm2_user_tab_cols")
    CALL parser("as select * from dm2_dba_tab_cols")
    CALL parser(concat("where owner = '",trim(currdbuser),"'"))
    CALL parser("go")
    IF (check_error("CREATING DM2_USER_TAB_COLS VIEW")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def4_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def4_exists_ind=1)
     DROP TABLE dm2_user_tab_cols
     IF (check_error("Dropping DM2_USER_TAB_COLS table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP DDLRECORD dm2_user_tab_cols FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD dm2_user_tab_cols FROM DATABASE v500
 TABLE dm2_user_tab_cols
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
  1 data_default  = vc32000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = dq8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_user_tab_cols
    IF (check_error("Creating DM2_USER_TAB_COLS table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def5_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def5_exists_ind=1)
     DROP TABLE product_component_version
     IF (check_error("Dropping PRODUCT_COMPONENT_VERSION table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP TABLE product_component_version
    DROP DDLRECORD product_component_version FROM DATABASE v500 WITH deps_deleted
    IF (currdbver < 19)
     CREATE DDLRECORD product_component_version FROM DATABASE v500
 TABLE product_component_version
  1 product  = vc80 CCL(product)
  1 version  = vc80 CCL(version)
  1 status  = vc80 CCL(status)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE product_component_version
    ELSE
     CREATE DDLRECORD product_component_version FROM DATABASE v500
 TABLE product_component_version
  1 product  = vc80 CCL(product)
  1 version  = vc80 CCL(version)
  1 version_full  = vc160 CCL(version_full)
  1 status  = vc80 CCL(status)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE product_component_version
    ENDIF
    IF (check_error("Creating PRODUCT_COMPONENT_VERSION table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_binary_search(search_item,record_structure,record_field) = i4
 SUBROUTINE dm2_binary_search(search_item,record_structure,record_field)
   DECLARE dbs_v_low = i4 WITH protect, noconstant(1)
   DECLARE dbs_v_mid = i4 WITH protect, noconstant(0)
   DECLARE dbs_v_high = i4 WITH protect, noconstant(0)
   CALL parser(concat("set dbs_v_high = size(",record_structure,",5) go"))
   WHILE (dbs_v_low <= dbs_v_high)
    SET dbs_v_mid = cnvtint(((dbs_v_high+ dbs_v_low)/ 2))
    IF (search_item=parser(build(record_structure,"[",dbs_v_mid,"]->",record_field)))
     RETURN(dbs_v_mid)
    ELSEIF (search_item < parser(build(record_structure,"[",dbs_v_mid,"]->",record_field)))
     SET dbs_v_high = (dbs_v_mid - 1)
    ELSE
     SET dbs_v_low = (dbs_v_mid+ 1)
    ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 IF (validate(retrieve_data->result_status,- (1)) < 0)
  FREE RECORD retrieve_data
  RECORD retrieve_data(
    1 result_str = vc
    1 result_status = i2
  )
  SET retrieve_data->result_status = 0
  SET retrieve_data->result_str = " "
 ENDIF
 DECLARE retrieve_data(sbr_srch_str=vc,sbr_sprtr=vc,sbr_rd_str=vc) = i2
 DECLARE dm2parse_output(sbr_attr_nbr=i4,sbr_parse_fname=vc,sbr_orientation=vc) = i2
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
 DECLARE drgcd_tab = vc WITH protect, noconstant("")
 DECLARE drgcd_r_tab = vc WITH protect, noconstant("")
 DECLARE drcd_debug_ind = i4 WITH protect, noconstant(0)
 DECLARE drgcd_idx = i4 WITH protect, noconstant(0)
 FREE RECORD crt_request
 RECORD crt_request(
   1 table_name = vc
   1 trig_ind = i2
   1 database_name = vc
 )
 FREE RECORD crt_reply
 RECORD crt_reply(
   1 status_data
     2 status = c1
     2 logfile = vc
 )
 SET dm_err->eproc = "Starting dm_rmc_generate_cutover_dml"
 IF (check_logfile("dm_rmc_gen_cut_dml",".log","DM_RMC_GEN_CUT_DML")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (reflect(parameter(1,0)) != "C*")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Expected syntax:  dm_rmc_generate_cutover_dml <Table_name>")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  SET drgcd_tab =  $1
 ENDIF
 SET drgcd_tab = cnvtupper(drgcd_tab)
 SET drgcd_r_tab = cutover_tab_name(drgcd_tab,"")
 CALL echo(drgcd_tab)
 CALL echo(drgcd_r_tab)
 FREE RECORD drgcd_stmts
 RECORD drgcd_stmts(
   1 stmt[*]
     2 str = vc
     2 end_ind = i2
     2 rdb_asis_ind = i2
     2 move_long_str_ind = i2
 )
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name=drgcd_r_tab
  WITH nocounter
 ;end select
 IF (check_error("While checking for existence of $R table: ")=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET crt_request->table_name = drgcd_tab
  SET crt_request->trig_ind = 1
  SELECT INTO "nl:"
   FROM v$database v
   DETAIL
    crt_request->database_name = v.name
   WITH nocounter
  ;end select
  EXECUTE dm_rmc_create_r_table  WITH replace("REQUEST","CRT_REQUEST"), replace("REPLY","CRT_REPLY")
  IF (check_error("While creating $R table ")=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 SET drcd_debug_ind = 1
 CALL create_merge_stmts(drgcd_tab,drgcd_stmts)
 CALL echo(
  "*****************************************************************************************************************"
  )
 FOR (drgcd_idx = 1 TO size(drgcd_stmts->stmt,5))
  CALL echo(drgcd_stmts->stmt[drgcd_idx].str)
  IF ((drgcd_stmts->stmt[drgcd_idx].end_ind=1))
   CALL echo(
    "*****************************************************************************************************************"
    )
   CALL echo("")
  ENDIF
 ENDFOR
#exit_program
END GO
