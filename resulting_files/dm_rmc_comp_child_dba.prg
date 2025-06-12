CREATE PROGRAM dm_rmc_comp_child:dba
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
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 IF ((validate(drc_tab_info->cnt,- (1))=- (1))
  AND (validate(drc_tab_info->cnt,- (2))=- (2)))
  FREE RECORD drc_tab_info
  RECORD drc_tab_info(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 r_table_name = vc
      2 batch_flag = i4
      2 batch_column = vc
      2 r_min_f8 = f8
      2 r_max_f8 = f8
      2 suffix = vc
      2 r_exist_ind = i2
      2 merge_delete_ind = i2
      2 current_state_ind = i2
      2 current_state_par_col = vc
      2 current_state_grp_col = vc
      2 current_state_parent = vc
      2 versioning_ind = i2
      2 versioning_alg = vc
      2 insert_only_ind = i2
      2 active_ind_ind = i2
      2 effective_col_ind = i2
      2 beg_col_name = vc
      2 end_col_name = vc
      2 active_name = vc
      2 root_column = vc
      2 meaningful_cnt = i4
      2 long_ind = i2
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
        3 root_entity_name = vc
        3 root_entity_attr = vc
        3 parent_entity_col = vc
        3 exception_flg = i4
        3 constant_value = vc
        3 ins_dml_override = vc
        3 upd_dml_override = vc
        3 unique_ident_ind = i2
        3 merge_delete_ind = i2
        3 defining_att_ind = i2
        3 meaningful_ind = i2
        3 meaningful_pos = i4
        3 notnull_ind = i2
        3 idcd_ind = i2
        3 pk_ind = i2
        3 ccl_data_type = vc
        3 db_data_type = vc
        3 long_ind = i2
        3 check_null = i2
        3 trailing_space_cnt = i4
  )
 ENDIF
 IF ((validate(drlc_meaningful->cnt,- (1))=- (1))
  AND (validate(drlc_meaningful->cnt,- (2))=- (2)))
  FREE RECORD drlc_meaningful
  RECORD drlc_meaningful(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
  )
 ENDIF
 IF ((validate(drlc_defining->cnt,- (1))=- (1))
  AND (validate(drlc_defining->cnt,- (2))=- (2)))
  FREE RECORD drlc_defining
  RECORD drlc_defining(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
    1 noncnt = i4
    1 nonqual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
    1 patcnt = i4
    1 patqual[*]
      2 str = vc
  )
 ENDIF
 DECLARE drc_get_meta_data(dgmd_rec=vc(ref),dgmd_table=vc) = i4
 DECLARE drcc_find_rows(dfr_info=vc(ref),dfr_tab_name=vc,dfr_context=vc,dfr_delete_ind=i2,dfr_batch=
  vc) = i2
 DECLARE drcc_create_report(dcr_file=vc,dcr_reply=vc(ref),dcr_new_ind=i2) = i2
 DECLARE drcc_get_meaningful(dgm_mstr=vc(ref),dgm_info=vc(ref),dgm_row_pos=i4,dgm_col_pos=i4,dgm_pos=
  i4) = i2
 DECLARE drcc_query_parent(dqp_map=vc(ref),dqp_info=vc(ref),dqp_table_name=vc,dqp_value=f8,dqp_r_ind=
  i2) = i2
 DECLARE drcc_get_batch(dgb_mstr=vc(ref),dbg_info=vc(ref),dgb_table=vc) = i2
 DECLARE drcc_load_report(dlr_mstr=vc(ref),dlr_info=vc(ref),dlr_temp=vc(ref),dlr_cur_pos=vc,
  dlr_env_name=vc,
  dlr_del_ind=i2) = i2
 DECLARE drcc_get_log_type(dglt_mstr=vc(ref),dglt_target_id=f8) = i2
 DECLARE drcc_get_inserts(dgi_info=vc(ref),dgi_cur_pos=i4,dgi_context=vc) = i4
 DECLARE drcc_log_error_info(dlei_table_name=vc,dlei_proc=vc,dlei_error=vc,dlei_name=vc) = i2
 DECLARE drcc_get_cut_cnt(dgcc_info=vc(ref),dgcc_cur_pos=i4) = i4
 SUBROUTINE drc_get_meta_data(dgmd_rec,dgmd_table)
   DECLARE dgmd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgmd_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgmd_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgmd_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE dgmd_done_ind = i4 WITH protect, noconstant(0)
   DECLARE dgmd_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgmd_max_mean = i4 WITH protect, noconstant(0)
   DECLARE dgmd_def_loop = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gathering table level meta-data"
   SELECT INTO "NL:"
    FROM dm_tables_doc_local drt
    WHERE drt.table_name=dgmd_table
    DETAIL
     dgmd_rec->cnt = (dgmd_rec->cnt+ 1), stat = alterlist(dgmd_rec->qual,dgmd_rec->cnt), dgmd_rec->
     qual[dgmd_rec->cnt].r_table_name = cutover_tab_name(drt.table_name,drt.table_suffix),
     dgmd_rec->qual[dgmd_rec->cnt].table_name = drt.table_name, dgmd_rec->qual[dgmd_rec->cnt].
     merge_delete_ind = drt.merge_delete_ind, dgmd_rec->qual[dgmd_rec->cnt].suffix = drt.table_suffix
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No table qualified for table ",dgmd_table," in table level meta-data")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Gathering column level meta data"
   SELECT INTO "NL:"
    FROM dm_columns_doc_local drt,
     user_tab_cols utc
    PLAN (drt
     WHERE drt.table_name=dgmd_table)
     JOIN (utc
     WHERE utc.table_name=dgmd_table
      AND utc.column_name=drt.column_name
      AND utc.virtual_column="NO"
      AND utc.hidden_column="NO"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char")))))
    DETAIL
     dgmd_col_cnt = (dgmd_col_cnt+ 1)
     IF (mod(dgmd_col_cnt,10)=1)
      stat = alterlist(dgmd_rec->qual[dgmd_rec->cnt].col_qual,(dgmd_col_cnt+ 9))
     ENDIF
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].column_name = drt.column_name, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].unique_ident_ind = drt.unique_ident_ind, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].exception_flg = drt.exception_flg,
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].constant_value = drt.constant_value,
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].parent_entity_col = cnvtupper(drt
      .parent_entity_col), dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_name =
     cnvtupper(drt.root_entity_name),
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_attr = cnvtupper(drt
      .root_entity_attr), dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].merge_delete_ind = drt
     .merge_delete_ind, dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].defining_att_ind = 1
     IF (drt.column_name IN ("*_ID", "*_CD", "CODE_VALUE")
      AND utc.data_type IN ("NUMBER", "FLOAT"))
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].idcd_ind = 1
     ELSE
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].idcd_ind = 0
     ENDIF
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].db_data_type = utc.data_type, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].check_null = 0
     IF (utc.data_type IN ("BLOB", "LONG RAW", "CLOB", "LONG"))
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].long_ind = 1, dgmd_rec->qual[dgmd_rec->cnt
      ].long_ind = 1
     ELSE
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].long_ind = 0
     ENDIF
     IF (drt.column_name="ACTIVE_IND")
      dgmd_rec->qual[dgmd_rec->cnt].active_ind_ind = 1, dgmd_rec->qual[dgmd_rec->cnt].active_name =
      drt.column_name
     ENDIF
     IF (drt.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
     "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
     "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM"))
      dgmd_rec->qual[dgmd_rec->cnt].beg_col_name = drt.column_name
     ENDIF
     IF (drt.column_name IN ("END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM",
     "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM"))
      dgmd_rec->qual[dgmd_rec->cnt].end_col_name = drt.column_name
     ENDIF
     IF (drt.table_name="PERSON"
      AND drt.column_name="PERSON_ID")
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_name = "PERSON", dgmd_rec->
      qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_attr = "PERSON_ID", dgmd_rec->qual[
      dgmd_rec->cnt].root_column = "PERSON_ID"
     ENDIF
     IF (drt.table_name=drt.root_entity_name
      AND drt.column_name=drt.root_entity_attr)
      dgmd_rec->qual[dgmd_rec->cnt].root_column = drt.column_name
     ENDIF
    FOOT REPORT
     stat = alterlist(dgmd_rec->qual[dgmd_rec->cnt].col_qual,dgmd_col_cnt), dgmd_rec->qual[dgmd_rec->
     cnt].col_cnt = dgmd_col_cnt
     IF ((dgmd_rec->qual[dgmd_rec->cnt].beg_col_name != "")
      AND (dgmd_rec->qual[dgmd_rec->cnt].end_col_name != ""))
      dgmd_rec->qual[dgmd_rec->cnt].effective_col_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No columns qualified from column level meta-data query for table ",
     dgmd_table)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((((dgmd_rec->qual[dgmd_rec->cnt].beg_col_name <= " ")) OR ((dgmd_rec->qual[dgmd_rec->cnt].
   end_col_name <= " "))) )
    SELECT INTO "NL:"
     FROM dm_refchg_attribute d
     WHERE d.table_name=dgmd_table
      AND d.attribute_name IN ("END_EFFECTIVE COLUMN_NAME_IND", "BEG_EFFECTIVE COLUMN_NAME_IND")
      AND d.attribute_value=1
     DETAIL
      IF (d.attribute_name="END_EFFECTIVE COLUMN_NAME_IND")
       dgmd_rec->qual[dgmd_rec->cnt].end_col_name = d.column_name
      ELSE
       dgmd_rec->qual[dgmd_rec->cnt].beg_col_name = d.column_name
      ENDIF
     FOOT REPORT
      IF ((dgmd_rec->qual[dgmd_rec->cnt].beg_col_name != "")
       AND (dgmd_rec->qual[dgmd_rec->cnt].end_col_name != ""))
       dgmd_rec->qual[dgmd_rec->cnt].effective_col_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm2_user_notnull_cols d
    WHERE d.table_name=dgmd_table
    DETAIL
     dgmd_col_idx = 0, dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,
      d.column_name,dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].column_name)
     IF (dgmd_col_idx > 0)
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].notnull_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    build(l.type,l.len), l.*, utc.data_type
    FROM dtableattr a,
     dtableattrl l,
     user_tab_columns utc
    PLAN (a
     WHERE a.table_name=dgmd_table)
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
     JOIN (utc
     WHERE utc.table_name=a.table_name
      AND utc.column_name=l.attr_name)
    DETAIL
     dgmd_col_idx = 0, dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,
      l.attr_name,dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].column_name)
     IF (dgmd_col_idx > 0)
      IF (l.type="F")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "F8"
      ELSEIF (l.type="I")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "I4"
      ELSEIF (l.type="C")
       IF (utc.data_type="CHAR")
        dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = build(l.type,l.len)
       ELSE
        dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "VC"
       ENDIF
      ELSEIF (l.type="Q")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "DQ8"
      ELSEIF (l.type="M")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "DM12"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=dgmd_table
     AND cv.code_set=4000220
     AND cv.active_ind=1
     AND cv.cdf_meaning="INSERT_ONLY"
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].insert_only_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=dgmd_table
     AND cv.code_set=255351
     AND cv.active_ind=1
     AND cv.cdf_meaning != "NONE"
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].versioning_ind = 1, dgmd_rec->qual[dgmd_rec->cnt].versioning_alg
      = cv.cdf_meaning
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(dgmd_rec->qual[dgmd_rec->cnt].col_cnt)),
     dm_info i
    PLAN (d
     WHERE (dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].idcd_ind=0))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",dgmd_rec->qual[dgmd_rec->cnt].table_name)
      AND (i.info_name=dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].column_name))
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].idcd_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,dguc_reply->rs_tbl_cnt,dgmd_table,dguc_reply->
    dtd_hold[dgmd_tbl_idx].tbl_name)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
     (dummyt d2  WITH seq = dguc_reply->dtd_hold[dgmd_tbl_idx].pk_cnt)
    PLAN (d)
     JOIN (d2
     WHERE (dguc_reply->dtd_hold[dgmd_tbl_idx].pk_hold[d2.seq].pk_name=dgmd_rec->qual[dgmd_rec->cnt].
     col_qual[d.seq].column_name))
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].pk_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_meaningful->cnt,dgmd_table,drlc_meaningful->qual[
    dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_meaningful->qual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_meaningful->qual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[dgmd_rec
      ->cnt].col_qual[d.seq].column_name)
       AND  NOT ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].db_data_type IN ("LONG*", "BLOB",
      "CLOB"))))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].meaningful_ind = 1, dgmd_rec->qual[dgmd_rec->cnt]
      .col_qual[d.seq].meaningful_pos = d2.seq, dgmd_rec->qual[dgmd_rec->cnt].meaningful_cnt = (
      dgmd_rec->qual[dgmd_rec->cnt].meaningful_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dgmd_max_mean = drlc_meaningful->qual[dgmd_tbl_idx].col_cnt
    FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
      IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col > " ")
       AND (dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].meaningful_ind=1))
       SET dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,dgmd_rec->
        qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col,dgmd_rec->qual[dgmd_rec->cnt].
        col_qual[dgmd_col_idx].column_name)
       SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_ind = 2
       IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_pos=0))
        SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_pos = (dgmd_max_mean+ 1)
        SET dgmd_max_mean = (dgmd_max_mean+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   FOR (dgmd_def_loop = 1 TO drlc_defining->patcnt)
     FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
       IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].column_name=patstring(drlc_defining
        ->patqual[dgmd_def_loop].str)))
        SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].defining_att_ind = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_defining->noncnt,dgmd_table,drlc_defining->
    nonqual[dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_defining->nonqual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_defining->nonqual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[
      dgmd_rec->cnt].col_qual[d.seq].column_name))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].defining_att_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_defining->cnt,dgmd_table,drlc_defining->qual[
    dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_defining->qual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_defining->qual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[dgmd_rec->
      cnt].col_qual[d.seq].column_name)
       AND  NOT ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].db_data_type IN ("LONG*", "BLOB",
      "CLOB"))))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].defining_att_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
     IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col > " ")
      AND (dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].defining_att_ind=1))
      SET dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,dgmd_rec->
       qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col,dgmd_rec->qual[dgmd_rec->cnt].
       col_qual[dgmd_col_idx].column_name)
      SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].defining_att_ind = 2
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM dm_refchg_dml d
    WHERE d.table_name=dgmd_table
     AND dml_attribute IN ("INS_VAL_STR", "UPD_VAL_STR")
    DETAIL
     dgmd_col_idx = locateval(dgmd_col_cnt,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,d.column_name,
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].column_name)
     IF (dgmd_col_idx > 0)
      IF (d.dml_attribute="INS_VAL_STR")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].ins_dml_override = d.dml_value
      ELSE
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].upd_dml_override = d.dml_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS AUDIT BATCH TABLE"
     AND d.info_name=dgmd_table
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].batch_flag = d.info_number, dgmd_rec->qual[dgmd_rec->cnt].
     batch_column = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgmd_table="DCP_FORMS_DEF")
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_ind = 1
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_par_col = "DCP_FORM_INSTANCE_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_grp_col = "DCP_FORMS_REF_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_parent = "DCP_FORMS_REF"
   ELSEIF (dgmd_table="DCP_INPUT_REF")
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_ind = 1
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_par_col = "DCP_SECTION_INSTANCE_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_grp_col = "DCP_SECTION_REF_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_parent = "DCP_SECTION_REF"
   ENDIF
   SELECT INTO "NL:"
    FROM user_tables u
    WHERE (u.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(- (2))
   ENDIF
   SELECT INTO "NL:"
    FROM dtable d
    WHERE (d.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind=0))
    WHILE (dgmd_done_ind=0)
      SET drl_reply->status = ""
      SET drl_reply->status_msg = ""
      CALL get_lock("RDDS $R CREATION",dgmd_rec->qual[dgmd_rec->cnt].r_table_name,0,drl_reply)
      IF ((drl_reply->status="F"))
       CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       SET dgmd_done_ind = 1
      ELSEIF ((drl_reply->status="S"))
       EXECUTE oragen3 dgmd_rec->qual[dgmd_rec->cnt].r_table_name
       SET dgmd_done_ind = 1
       SET drl_reply->status = ""
       SET drl_reply->status_msg = ""
       CALL remove_lock("RDDS $R CREATION",dgmd_rec->qual[dgmd_rec->cnt].r_table_name,currdbhandle,
        drl_reply)
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg("",dm_err->logfile,1)
        SET dgmd_done_ind = 1
       ENDIF
      ELSE
       CALL pause(10)
       SELECT INTO "NL:"
        FROM dtable d
        WHERE (d.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
        DETAIL
         dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind = 1
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dgmd_done_ind = 1
       ENDIF
       IF ((dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind=1))
        SET dgmd_done_ind = 1
       ELSE
        IF (dgmd_retry_cnt=3)
         CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
         SET dm_err->emsg = drl_reply->status_msg
         SET dm_err->err_ind = 1
         SET dgmd_done_ind = 1
        ENDIF
        SET dgmd_retry_cnt = (dgmd_retry_cnt+ 1)
       ENDIF
      ENDIF
    ENDWHILE
    RETURN(- (1))
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(dgmd_rec->cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcc_find_rows(dfr_info,dfr_tab_name,dfr_context,dfr_delete_ind,dfr_batch_str)
   DECLARE dfr_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dfr_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_tab = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_r_table = vc WITH protect, noconstant("")
   DECLARE dfr_pk_where = vc WITH protect, noconstant("")
   DECLARE dfr_col_list = vc WITH protect, noconstant("")
   DECLARE dfr_pe_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dfr_stmt_cnt = i4
   DECLARE dfr_dtype_def = vc
   FREE RECORD dfr_stmt
   RECORD dfr_stmt(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD dfr_temp
   RECORD dfr_temp(
     1 cnt = i4
     1 stmt[*]
       2 str = vc
   )
   SET dfr_tab_pos = locateval(dfr_tab_loop,1,dfr_info->cnt,dfr_tab_name,dfr_info->qual[dfr_tab_loop]
    .table_name)
   SET dfr_pk_where = concat(" (r.RDDS_DELETE_IND = ",trim(cnvtstring(dfr_delete_ind)),
    " and r.rdds_status_flag < 9000")
   IF (dfr_context != char(42))
    SET dfr_pk_where = concat(dfr_pk_where," and (r.rdds_context_name = '",dfr_context,
     "' or r.rdds_context_name like '",dfr_context,
     "::%' or r.rdds_context_name like '%::",dfr_context,"' or r.rdds_context_name like '%::",
     dfr_context,"::%')")
   ENDIF
   SET dm_err->eproc = "Evaluate generic non-delete rows"
   SET stat = alterlist(dfr_stmt->stmt,4000)
   SET dfr_stmt->stmt[1].str =
   "rdb asis(^ insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value,^) "
   IF (dfr_delete_ind=0)
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
   ELSE
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value,r_rowid,r_ptam_hash_value,status)(select distinct vals_r.tname as tabname,^)"
   ENDIF
   SET dfr_stmt->stmt[3].str =
   "asis(^vals_r.cname as colname, vals_r.value as r_value, vals_l.value as l_value,^)"
   SET dfr_stmt->stmt[4].str =
   "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
   SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
    dfr_info->qual[dfr_tab_pos].table_name," l, ^)")
   SET dfr_stmt->stmt[6].str = concat("asis(^")
   IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)
    SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str,dfr_info->qual[dfr_tab_pos].
     current_state_parent," s, ")
   ENDIF
   SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str," table ( column_diff_varray (^)")
   SET dfr_stmt_cnt = 7
   SET stat = alterlist(dfr_temp->stmt,1000)
   SET dfr_temp->cnt = 1
   IF (dfr_delete_ind=1
    AND (dfr_info->qual[dfr_tab_pos].merge_delete_ind=0))
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF (dfr_delete_ind=1
    AND (dfr_info->qual[dfr_tab_pos].merge_delete_ind=1))
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
    AND (dfr_info->qual[dfr_tab_pos].versioning_ind=0)
    AND (dfr_info->qual[dfr_tab_pos].current_state_ind=0)) OR ((dfr_info->qual[dfr_tab_pos].
   versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG2"))) )
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].defining_att_ind=1)) OR ((((dfr_info
      ->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((dfr_info->qual[dfr_tab_pos].
      col_qual[dfr_col_loop].pk_ind=1))) ))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].defining_att_ind=1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].root_column)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDFOR
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R, table ( column_diff_varray ( ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
      "r.rdds_ptam_match_result","-1",0)
     SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDFOR
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_L where ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)
    SET dfr_par_tab = locateval(dfr_par_loop,1,dfr_info->cnt,dfr_info->qual[dfr_tab_pos].
     current_state_parent,dfr_info->qual[dfr_par_loop].table_name)
    IF (dfr_par_tab=0)
     SET dfr_par_tab = drc_get_meta_data(dfr_info,dfr_info->qual[dfr_tab_pos].current_state_parent)
     IF (dfr_par_tab=0)
      RETURN(1)
     ELSEIF ((dfr_par_tab=- (1)))
      RETURN(- (1))
     ELSEIF ((dfr_par_tab=- (2)))
      SET dfr_par_tab = dfr_info->cnt
      SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].table_name
     ELSE
      SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].r_table_name
     ENDIF
    ELSE
     SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].r_table_name
    ENDIF
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
     current_state_par_col," in (select r1.",dfr_info->qual[dfr_par_tab].root_column," from ",
     dfr_par_r_table," r1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
     AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r1.",0),
       ") and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and r1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",r1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"r1.","r2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," r2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r2.",0),
        ") and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and s.",dfr_info->qual[dfr_tab_pos].
      current_state_grp_col," = r.",dfr_info->qual[dfr_tab_pos].current_state_grp_col,"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (s.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (s.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and s.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ s.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"s.","l2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_par_tab].
        table_name," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," = s.",dfr_info->qual[dfr_tab_pos].current_state_par_col,"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
        AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
       dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
       column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and (1 = 1 ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
      " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
      " is currently not supported")
     RETURN(1)
    ENDIF
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
    AND ((dfr_delete_ind=0
    AND  NOT ((dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))) OR (
   dfr_delete_ind=1)) )
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF (dfr_delete_ind=0
    AND (dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
      active_name," = 0 and r.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate and not (^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_col_list = ""
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
         SET dfr_dtype_def = "'AbyZ12%$90'"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
         SET dfr_dtype_def = "-123"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type="F8"))
         SET dfr_dtype_def = "-123.456"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"))
        )
         SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
        ENDIF
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=1))
         IF (dfr_col_list="")
          SET dfr_col_list = concat("r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
           column_name)
         ELSE
          SET dfr_col_list = concat(dfr_col_list,",r.",dfr_info->qual[dfr_tab_pos].col_qual[
           dfr_col_loop].column_name)
         ENDIF
        ELSE
         IF (dfr_col_list="")
          SET dfr_col_list = concat("nvl(","r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
           column_name,",",dfr_dtype_def,
           ")")
         ELSE
          SET dfr_col_list = concat(dfr_col_list,",nvl(","r.",dfr_info->qual[dfr_tab_pos].col_qual[
           dfr_col_loop].column_name,",",
           dfr_dtype_def,")")
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
       dfr_col_list,"r.","r1.",0),"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
      r_table_name," r1 where r1.",dfr_info->qual[dfr_tab_pos].active_name," = 1))^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (l.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
      active_name," = 0 and l.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate and not (^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"r.","l.",0),
      ") in (select ",replace(dfr_col_list,"r.","l1.",0),"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
      table_name," l1 where l1.",dfr_info->qual[dfr_tab_pos].active_name," = 1))^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=0)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = " asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = " asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Table type not able to be identified: ",dfr_info->qual[dfr_tab_pos].
     table_name)
    RETURN(1)
   ENDIF
   SET dfr_stmt->stmt[dfr_stmt_cnt].str =
   "asis(^) and (vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   IF (dfr_delete_ind=0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and (vals_r.value != vals_l.value ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat(
     "asis(^ or ((vals_r.value is null and vals_l.value is not null) or ",
     " (vals_r.value is not null and vals_l.value is null)))^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDIF
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ))^) go"
   SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
   IF (drlc_debug_flag > 0)
    SELECT INTO "dm_rmc_r_live_debug.txt"
     FROM (dummyt d  WITH seq = dfr_stmt_cnt)
     DETAIL
      dfr_stmt->stmt[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=0) OR ((((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
    AND dfr_delete_ind=0) OR ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)) )) )
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, 'RDDS NO VAL',^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     " table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind >= 1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select r1.",dfr_info->qual[dfr_par_tab].root_column," from ",
      dfr_par_r_table," r1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r1.",0),
        ") and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and r1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r1.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",r1.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop]
             .column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","r1.",dfr_info->qual[dfr_par_tab].
             col_qual[dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"r1.","r2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," r2 where ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF (findstring("$R",dfr_par_r_table,0,0) > 0)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r2.",0),
         ") and ^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r2.",dfr_info->qual[dfr_par_tab].
        active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
       " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
       " is currently not supported")
      RETURN(1)
     ENDIF
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and exists (select 'x' from ",dfr_info->
     qual[dfr_tab_pos].table_name," l1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_and_ind = 0
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name=dfr_info->qual[dfr_tab_pos
      ].current_state_grp_col))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].exception_flg=12))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l1.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_tab_pos].current_state_parent," d1 ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ where (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       current_state_parent," d2 where d2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and not exists (select 'x' from ",
     dfr_info->qual[dfr_tab_pos].table_name," l2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_and_ind = 0
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_batch_str,"<suffix>","l2",0),
      " ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_and_ind = 1
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
      column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l2.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_tab_pos].current_state_parent," d1 ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ where (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       current_state_parent," d2 where d2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ELSE
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^) go "
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_l.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_l.cname as colname, 'RDDS NO VAL', vals_l.value as l_value,^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_l.r_rowid as r_rowid, vals_l.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].table_name," l, ^)")
    SET dfr_stmt->stmt[6].str = "asis(^"
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str,dfr_info->qual[dfr_tab_pos].
      current_state_parent," s, ")
    ENDIF
    SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str," table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 7
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
       "r.rdds_ptam_match_result","-1",0)
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_L where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (s.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (s.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and s.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ s.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"s.","l2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
        current_state_parent," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
       current_state_par_col," = s.",dfr_info->qual[dfr_tab_pos].current_state_par_col," and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
       " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
       " is currently not supported")
      RETURN(1)
     ENDIF
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ exists (select 'x' from ",dfr_info->qual[
     dfr_tab_pos].r_table_name," r1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_pk_where = replace(dfr_pk_where,"r.","r1.",0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
       "r1",0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name=dfr_info->qual[dfr_tab_pos
      ].current_state_grp_col))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r1.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].exception_flg=12))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r1.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_par_r_table," d1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d1.",0),
       ")^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^  and (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," d2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d2.",0),
        ")^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and d2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and not exists (select 'x' from ",
     dfr_info->qual[dfr_tab_pos].r_table_name," r2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_pk_where = replace(dfr_pk_where,"r1.","r2.",0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
       "r2",0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
      column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r2.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_par_r_table," d1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d1.",0),
       ")^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," d2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d2.",0),
        ")^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and d2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^) go "
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET dfr_pk_where = replace(dfr_pk_where,"r2.","r.",0)
   ENDIF
   IF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4"))
    AND dfr_delete_ind=0)
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, 'RDDS NO VAL',^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     dfr_info->qual[dfr_tab_pos].table_name," l,",
     " table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind >= 1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
     active_name," = 0^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
      end_col_name," <= sysdate ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and not exists (select 'x' from ",dfr_info
     ->qual[dfr_tab_pos].r_table_name," r1 where (^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^r1.",dfr_info->qual[dfr_tab_pos].active_name,
     " = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or r1.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and ",replace(dfr_pk_where,"r.","r1.",0),
     ")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat(
     "asis(^) and r.updt_dt_tm in (select max(r2.updt_Dt_Tm) from ",dfr_info->qual[dfr_tab_pos].
     r_table_name," r2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r.","r2.",0),")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^))^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^) go"
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF (dfr_delete_ind=0)
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, vals_l.value as l_value,^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     dfr_info->qual[dfr_tab_pos].table_name," l, table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[
      dfr_col_loop].unique_ident_ind=1))) ))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R , table ( column_diff_varray (^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
       "r.rdds_ptam_match_result","-1",0)
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) VALS_L where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str =
    "asis(^ and r.rowid in (select r_rowid from dm_refchg_comp_gttd))^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
        AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
       dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
       column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select l1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_par_tab].table_name," l1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
      AND dfr_batch_str > " ")
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_batch_str,"<suffix>","l1",0
        )," and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and l1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"d1.","l1.",0),
       ") in (select ",replace(dfr_col_list,"d1.","l2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_par_tab].
       table_name," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
       AND dfr_batch_str > " ")
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
         "l2",0)," ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) and (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
     AND (dfr_info->qual[dfr_tab_pos].versioning_ind=0)) OR ((dfr_info->qual[dfr_tab_pos].
    versioning_ind=1)
     AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG2", "ALG5")))) )
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ELSE
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ( ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
     AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (l.",dfr_info->qual[dfr_tab_pos].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
       active_name," = 0 and l.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l.",dfr_info->qual[dfr_tab_pos].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"r.","l.",0),
       ") in (select ",replace(dfr_col_list,"r.","l1.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       table_name," l1 where l1.",dfr_info->qual[dfr_tab_pos].active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
       AND dfr_batch_str > " ")
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
         "l1",0)," ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) and (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].parent_entity_col," = l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
         SET dfr_pe_col_idx = locateval(dfr_pe_col_idx,1,dfr_info->qual[dfr_tab_pos].col_cnt,dfr_info
          ->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col,dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_pe_col_idx].column_name)
         IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_pe_col_idx].notnull_ind=0))
          SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
           col_qual[dfr_pe_col_idx].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].
           col_qual[dfr_pe_col_idx].column_name," is null)^)")
          SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
         ENDIF
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ELSE
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ( ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or vals_r.cname = '",dfr_info->qual[
          dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col,"'^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Table type not able to be identified: ",dfr_info->qual[dfr_tab_pos].
      table_name)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_create_report(dcr_file,dcr_reply,dcr_new_ind)
   IF (dcr_new_ind=1)
    SELECT INTO value(dcr_file)
     FROM (dummyt d  WITH seq = dcr_reply->text_cnt)
     DETAIL
      dcr_reply->text_qual[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none
    ;end select
   ELSE
    SELECT INTO value(dcr_file)
     FROM (dummyt d  WITH seq = dcr_reply->text_cnt)
     DETAIL
      dcr_reply->text_qual[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
   IF (check_error("Create header for table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_meaningful(dgm_mstr,dgm_info,dgm_row_pos,dgm_col_pos,dgm_pos)
   DECLARE dgm_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgm_ret_ind = i2 WITH protect, noconstant(0)
   DECLARE dgm_parent = vc WITH protect, noconstant("")
   DECLARE dgm_pe_name_idx = i4 WITH protect, noconstant(0)
   DECLARE dgm_unresolved_ind = i2 WITH protect, noconstant(0)
   DECLARE dgm_m_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_un_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_md_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_md_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_break = vc WITH protect, noconstant("")
   DECLARE dgm_md_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_idx = i4 WITH protect, noconstant(0)
   FREE RECORD dgm_map
   RECORD dgm_map(
     1 col_cnt = i4
     1 col_qual[*]
       2 table_name = vc
       2 column_name = vc
       2 column_value = vc
       2 null_ind = i2
       2 t_space_cnt = i4
       2 mngfl_pos = i4
   )
   FREE RECORD dgm_unresolved
   RECORD dgm_unresolved(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 column_value = vc
       2 tspace_cnt = i4
       2 resolved_ind = i2
       2 level = i2
   )
   SET dgm_col_idx = locateval(dgm_col_loop,1,dgm_info->qual[dgm_pos].col_cnt,dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].column_name,dgm_info->qual[dgm_pos].col_qual[dgm_col_loop].
    column_name)
   IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_null_ind=1))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = "[NULL]"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value="RDDS NO VAL"))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = "RDDS NO VAL"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSE
    IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].ccl_data_type IN ("DQ8", "DM12", "VC", "C*")))
     IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_tscnt > 0)
      AND size(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value)=0)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = fillstring(value(
        dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_tscnt),"<")
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,"<","<SPACE>",0)
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].r_value
     ENDIF
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
      dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
      diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,char(0),"<CHAR(0)>",0)
    ELSE
     IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].idcd_ind=1)
      AND  NOT ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].exception_flg IN (1, 6, 7, 9, 10,
     11)))
      AND value(dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].constant_value)=null)
      IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name != dgm_info->qual[dgm_pos].
      root_column))
       SET dgm_unresolved_ind = 1
       SET dgm_unresolved->cnt = 1
       SET stat = alterlist(dgm_unresolved->qual,1)
       SET dgm_unresolved->qual[1].table_name = dgm_info->qual[dgm_pos].table_name
       SET dgm_unresolved->qual[1].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].r_value
       SET dgm_unresolved->qual[1].column_name = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].column_name
       SET dgm_unresolved->qual[1].level = 1
       IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col > " "))
        SET dgm_unresolved->cnt = 2
        SET stat = alterlist(dgm_unresolved->qual,2)
        SET dgm_unresolved->qual[2].table_name = dgm_info->qual[dgm_pos].table_name
        SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_mstr->diff_qual[dgm_row_pos].col_cnt,
         dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col,dgm_mstr->diff_qual[
         dgm_row_pos].col_qual[dgm_pe_name_idx].column_name)
        SET dgm_unresolved->qual[2].column_name = dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
        parent_entity_col
        SET dgm_unresolved->qual[2].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
        dgm_pe_name_idx].r_value
        SET dgm_unresolved->qual[2].level = 1
        SET dgm_unresolved->qual[2].resolved_ind = 1
       ENDIF
       WHILE (dgm_unresolved_ind=1)
         FOR (dgm_un_loop = 1 TO dgm_unresolved->cnt)
           IF ((dgm_unresolved->qual[dgm_un_loop].resolved_ind=0))
            IF (cnvtreal(dgm_unresolved->qual[dgm_un_loop].column_value) <= 0.0)
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->
             diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info
              ->qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
              column_name)
            ELSE
             SET dgm_md_tab_pos = locateval(dgm_md_tab_loop,1,dgm_info->cnt,dgm_unresolved->qual[
              dgm_un_loop].table_name,dgm_info->qual[dgm_md_tab_loop].table_name)
             SET dgm_md_col_pos = locateval(dgm_col_loop,1,dgm_info->qual[dgm_md_tab_pos].col_cnt,
              dgm_unresolved->qual[dgm_un_loop].column_name,dgm_info->qual[dgm_md_tab_pos].col_qual[
              dgm_col_loop].column_name)
             IF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].root_entity_name > " "))
              SET dgm_parent = dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].
              root_entity_name
             ELSEIF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col > " "
             ))
              SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_unresolved->cnt,dgm_info->qual[
               dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[
               dgm_pe_name_idx].column_name)
              SELECT INTO "NL:"
               var_str = evaluate_pe_name(dgm_info->qual[dgm_md_tab_pos].table_name,dgm_info->qual[
                dgm_md_tab_pos].col_qual[dgm_md_col_pos].column_name,dgm_info->qual[dgm_md_tab_pos].
                col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[dgm_pe_name_idx].
                column_value)
               FROM dual d
               DETAIL
                dgm_parent = var_str
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               RETURN(1)
              ENDIF
             ELSE
              SET dgm_parent = "INVALIDTABLE"
             ENDIF
             IF (dgm_parent="INVALIDTABLE")
              SET dm_err->err_ind = 1
              SET dm_err->emsg = concat("No parent table could be found for ",dgm_info->qual[
               dgm_md_tab_pos].table_name,".",dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos]
               .column_name)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(1)
             ENDIF
             SET dgm_map->col_cnt = 0
             SET stat = alterlist(dgm_map->col_qual,0)
             SET dgm_ret_ind = drcc_query_parent(dgm_map,dgm_info,dgm_parent,cnvtreal(dgm_unresolved
               ->qual[dgm_un_loop].column_value),1)
             IF (((dgm_ret_ind=1) OR ((dgm_ret_ind=- (1)))) )
              RETURN(dgm_ret_ind)
             ENDIF
             SET stat = alterlist(dgm_unresolved->qual,(dgm_unresolved->cnt+ dgm_map->col_cnt))
             IF ((dgm_un_loop < dgm_unresolved->cnt))
              SET dgm_m_loop = dgm_unresolved->cnt
              WHILE (dgm_m_loop > dgm_un_loop)
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].table_name = dgm_unresolved
                ->qual[dgm_m_loop].table_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_name = dgm_unresolved
                ->qual[dgm_m_loop].column_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_value =
                dgm_unresolved->qual[dgm_m_loop].column_value
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].tspace_cnt = dgm_unresolved
                ->qual[dgm_m_loop].tspace_cnt
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].resolved_ind =
                dgm_unresolved->qual[dgm_m_loop].resolved_ind
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].level = dgm_unresolved->
                qual[dgm_m_loop].level
                SET dgm_m_loop = (dgm_m_loop - 1)
              ENDWHILE
             ENDIF
             FOR (dgm_m_loop = 1 TO dgm_map->col_cnt)
               SET dgm_m_pos = locateval(dgm_m_idx,1,dgm_map->col_cnt,dgm_m_loop,dgm_map->col_qual[
                dgm_m_idx].mngfl_pos)
               SET dgm_m_tab_pos = locateval(dgm_m_idx,1,dgm_info->cnt,dgm_parent,dgm_info->qual[
                dgm_m_idx].table_name)
               IF ((dgm_map->col_qual[dgm_m_pos].column_name != "NOMEAN"))
                SET dgm_m_col_pos = locateval(dgm_m_idx,1,dgm_info->qual[dgm_m_tab_pos].col_cnt,
                 dgm_map->col_qual[dgm_m_pos].column_name,dgm_info->qual[dgm_m_tab_pos].col_qual[
                 dgm_m_idx].column_name)
               ENDIF
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].table_name = dgm_map->col_qual[
               dgm_m_pos].table_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_name = dgm_map->col_qual[
               dgm_m_pos].column_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].tspace_cnt = dgm_map->col_qual[
               dgm_m_pos].t_space_cnt
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].level = (dgm_unresolved->qual[
               dgm_un_loop].level+ 1)
               IF ((dgm_map->col_qual[dgm_m_pos].null_ind=1))
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = "[NULL]"
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
               ELSE
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = dgm_map->col_qual[
                dgm_m_pos].column_value
                IF ((dgm_map->col_qual[dgm_m_pos].column_name="NOMEAN"))
                 SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                ELSE
                 IF ((dgm_info->qual[dgm_m_tab_pos].col_qual[dgm_m_col_pos].idcd_ind=0))
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                 ELSE
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 0
                 ENDIF
                ENDIF
               ENDIF
             ENDFOR
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_unresolved->cnt = (dgm_unresolved->cnt+ dgm_map->col_cnt)
            ENDIF
            SET dgm_unresolved_ind = 0
            FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
              IF ((dgm_unresolved->qual[dgm_m_loop].resolved_ind=0))
               SET dgm_unresolved_ind = 1
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
       ENDWHILE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_cnt = (dgm_unresolved->cnt
        - 1)
       SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual,(
        dgm_unresolved->cnt - 1))
       FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
         IF (dgm_m_loop=1)
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_unresolved->
          qual[dgm_m_loop].column_value
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(
            dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[dgm_m_loop].
            column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = dgm_unresolved->
           qual[dgm_m_loop].table_name
          ENDIF
         ELSE
          IF ((dgm_unresolved->qual[dgm_m_loop].tspace_cnt > 0))
           IF (size(dgm_unresolved->qual[dgm_m_loop].column_value)=0)
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = fillstring(value(dgm_unresolved->qual[dgm_m_loop].tspace_cnt),"<")
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = replace(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(
             dgm_m_loop - 1)].mean_str,"<","<SPACE>",0)
           ELSE
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = concat("(",dgm_unresolved->qual[dgm_m_loop].column_value,fillstring(value(
               dgm_unresolved->qual[dgm_m_loop].tspace_cnt)," "),")")
           ENDIF
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           mean_str = dgm_unresolved->qual[dgm_m_loop].column_value
          ENDIF
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           trans_str = concat(dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[
            dgm_m_loop].column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           trans_str = dgm_unresolved->qual[dgm_m_loop].table_name
          ENDIF
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
          level = dgm_unresolved->qual[dgm_m_loop].level
         ENDIF
       ENDFOR
      ELSE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
       dgm_row_pos].col_qual[dgm_col_pos].r_value
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->
        qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      ENDIF
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].r_value
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
       dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,char(0),"<CHAR(0)>",0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_null_ind=1))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = "[NULL]"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value=dgm_mstr->diff_qual[
   dgm_row_pos].col_qual[dgm_col_pos].r_value))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_mean_str
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_trans_str
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_tscnt
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_level_cnt
    SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual,dgm_mstr
     ->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt)
    FOR (dgm_m_loop = 1 TO dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].mean_str =
      dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].mean_str
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].trans_str
       = dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].trans_str
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].level =
      dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].level
    ENDFOR
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value="RDDS NO VAL"))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = "RDDS NO VAL"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSE
    IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].ccl_data_type IN ("DQ8", "DM12", "VC", "C*")))
     IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt > 0)
      AND size(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value)=0)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = fillstring(value(
        dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt),"<")
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,"<","<SPACE>",0)
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].l_value
     ENDIF
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
      dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
      diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,char(0),"<CHAR(0)>",0)
    ELSE
     IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].idcd_ind=1)
      AND  NOT ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].exception_flg IN (1, 6, 7, 9, 10,
     11)))
      AND value(dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].constant_value)=null)
      IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name != dgm_info->qual[dgm_pos].
      root_column))
       SET dgm_unresolved_ind = 1
       SET dgm_unresolved->cnt = 1
       SET stat = alterlist(dgm_unresolved->qual,1)
       SET dgm_unresolved->qual[1].table_name = dgm_info->qual[dgm_pos].table_name
       SET dgm_unresolved->qual[1].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].l_value
       SET dgm_unresolved->qual[1].column_name = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].column_name
       SET dgm_unresolved->qual[1].resolved_ind = 0
       SET dgm_unresolved->qual[1].level = 1
       IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col > " "))
        SET dgm_unresolved->cnt = 2
        SET stat = alterlist(dgm_unresolved->qual,2)
        SET dgm_unresolved->qual[2].table_name = dgm_info->qual[dgm_pos].table_name
        SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_mstr->diff_qual[dgm_row_pos].col_cnt,
         dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col,dgm_mstr->diff_qual[
         dgm_row_pos].col_qual[dgm_pe_name_idx].column_name)
        SET dgm_unresolved->qual[2].column_name = dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
        parent_entity_col
        SET dgm_unresolved->qual[2].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
        dgm_pe_name_idx].l_value
        SET dgm_unresolved->qual[2].level = 1
        SET dgm_unresolved->qual[2].resolved_ind = 1
       ENDIF
       WHILE (dgm_unresolved_ind=1)
         FOR (dgm_un_loop = 1 TO dgm_unresolved->cnt)
           IF ((dgm_unresolved->qual[dgm_un_loop].resolved_ind=0))
            IF (cnvtreal(dgm_unresolved->qual[dgm_un_loop].column_value) <= 0.0)
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->
             diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info
              ->qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
              column_name)
            ELSE
             SET dgm_md_tab_pos = locateval(dgm_md_tab_loop,1,dgm_info->cnt,dgm_unresolved->qual[
              dgm_un_loop].table_name,dgm_info->qual[dgm_md_tab_loop].table_name)
             SET dgm_md_col_pos = locateval(dgm_col_loop,1,dgm_info->qual[dgm_md_tab_pos].col_cnt,
              dgm_unresolved->qual[dgm_un_loop].column_name,dgm_info->qual[dgm_md_tab_pos].col_qual[
              dgm_col_loop].column_name)
             IF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].root_entity_name > " "))
              SET dgm_parent = dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].
              root_entity_name
             ELSEIF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col > " "
             ))
              SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_unresolved->cnt,dgm_info->qual[
               dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[
               dgm_pe_name_idx].column_name)
              SELECT INTO "NL:"
               var_str = evaluate_pe_name(dgm_info->qual[dgm_md_tab_pos].table_name,dgm_info->qual[
                dgm_md_tab_pos].col_qual[dgm_md_col_pos].column_name,dgm_info->qual[dgm_md_tab_pos].
                col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[dgm_pe_name_idx].
                column_value)
               FROM dual d
               DETAIL
                dgm_parent = var_str
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               RETURN(1)
              ENDIF
             ELSE
              SET dgm_parent = "INVALIDTABLE"
             ENDIF
             IF (dgm_parent="INVALIDTABLE")
              SET dm_err->err_ind = 1
              SET dm_err->emsg = concat("No parent table could be found for ",dgm_info->qual[
               dgm_md_tab_pos].table_name,".",dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos]
               .column_name)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(1)
             ENDIF
             SET dgm_map->col_cnt = 0
             SET stat = alterlist(dgm_map->col_qual,0)
             SET dgm_ret_ind = drcc_query_parent(dgm_map,dgm_info,dgm_parent,cnvtreal(dgm_unresolved
               ->qual[dgm_un_loop].column_value),1)
             IF (((dgm_ret_ind=1) OR ((dgm_ret_ind=- (1)))) )
              RETURN(dgm_ret_ind)
             ENDIF
             SET stat = alterlist(dgm_unresolved->qual,(dgm_unresolved->cnt+ dgm_map->col_cnt))
             IF ((dgm_un_loop < dgm_unresolved->cnt))
              SET dgm_m_loop = dgm_unresolved->cnt
              WHILE (dgm_m_loop > dgm_un_loop)
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].table_name = dgm_unresolved
                ->qual[dgm_m_loop].table_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_name = dgm_unresolved
                ->qual[dgm_m_loop].column_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_value =
                dgm_unresolved->qual[dgm_m_loop].column_value
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].tspace_cnt = dgm_unresolved
                ->qual[dgm_m_loop].tspace_cnt
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].resolved_ind =
                dgm_unresolved->qual[dgm_m_loop].resolved_ind
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].level = dgm_unresolved->
                qual[dgm_m_loop].level
                SET dgm_m_loop = (dgm_m_loop - 1)
              ENDWHILE
             ENDIF
             FOR (dgm_m_loop = 1 TO dgm_map->col_cnt)
               SET dgm_m_pos = locateval(dgm_m_pos,1,dgm_map->col_cnt,dgm_m_loop,dgm_map->col_qual[
                dgm_m_pos].mngfl_pos)
               SET dgm_m_tab_pos = locateval(dgm_m_tab_pos,1,dgm_info->cnt,dgm_parent,dgm_info->qual[
                dgm_m_tab_pos].table_name)
               IF ((dgm_map->col_qual[dgm_m_pos].column_name != "NOMEAN"))
                SET dgm_m_col_pos = locateval(dgm_m_col_pos,1,dgm_info->qual[dgm_m_tab_pos].col_cnt,
                 dgm_map->col_qual[dgm_m_pos].column_name,dgm_info->qual[dgm_m_tab_pos].col_qual[
                 dgm_m_col_pos].column_name)
               ENDIF
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].table_name = dgm_map->col_qual[
               dgm_m_pos].table_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_name = dgm_map->col_qual[
               dgm_m_pos].column_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].tspace_cnt = dgm_map->col_qual[
               dgm_m_pos].t_space_cnt
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].level = (dgm_unresolved->qual[
               dgm_un_loop].level+ 1)
               IF ((dgm_map->col_qual[dgm_m_pos].null_ind=1))
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = "[NULL]"
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
               ELSE
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = dgm_map->col_qual[
                dgm_m_pos].column_value
                IF ((dgm_map->col_qual[dgm_m_pos].column_name="NOMEAN"))
                 SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                ELSE
                 IF ((dgm_info->qual[dgm_m_tab_pos].col_qual[dgm_m_col_pos].idcd_ind=0))
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                 ELSE
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 0
                 ENDIF
                ENDIF
               ENDIF
             ENDFOR
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_unresolved->cnt = (dgm_unresolved->cnt+ dgm_map->col_cnt)
            ENDIF
            SET dgm_unresolved_ind = 0
            FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
              IF ((dgm_unresolved->qual[dgm_m_loop].resolved_ind=0))
               SET dgm_unresolved_ind = 1
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
       ENDWHILE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt = (dgm_unresolved->cnt
        - 1)
       SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual,(
        dgm_unresolved->cnt - 1))
       FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
         IF (dgm_m_loop=1)
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_unresolved->
          qual[dgm_m_loop].column_value
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(
            dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[dgm_m_loop].
            column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = dgm_unresolved->
           qual[dgm_m_loop].table_name
          ENDIF
         ELSE
          IF ((dgm_unresolved->qual[dgm_m_loop].tspace_cnt > 0))
           IF (size(dgm_unresolved->qual[dgm_m_loop].column_value)=0)
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = fillstring(value(dgm_unresolved->qual[dgm_m_loop].tspace_cnt),"<")
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = replace(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(
             dgm_m_loop - 1)].mean_str,"<","<SPACE>",0)
           ELSE
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = concat("(",dgm_unresolved->qual[dgm_m_loop].column_value,fillstring(value(
               dgm_unresolved->qual[dgm_m_loop].tspace_cnt)," "),")")
           ENDIF
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           mean_str = dgm_unresolved->qual[dgm_m_loop].column_value
          ENDIF
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           trans_str = concat(dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[
            dgm_m_loop].column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           trans_str = dgm_unresolved->qual[dgm_m_loop].table_name
          ENDIF
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
          level = dgm_unresolved->qual[dgm_m_loop].level
         ENDIF
       ENDFOR
      ELSE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
       dgm_row_pos].col_qual[dgm_col_pos].l_value
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->
        qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      ENDIF
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].l_value
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
       dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,char(0),"<CHAR(0)>",0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_query_parent(dqp_map,dqp_info,dqp_tab_name,dqp_value,dqp_r_ind)
   DECLARE dqp_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dqp_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dqp_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dqp_root_col = vc WITH protect, noconstant("")
   DECLARE dqp_query_tab = vc WITH protect, noconstant("")
   DECLARE dqp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dqp_qual = i4 WITH protect, noconstant(0)
   DECLARE dqp_retry_ind = i2 WITH protect, noconstant(0)
   DECLARE dqp_done_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dqp_parse
   RECORD dqp_parse(
     1 stmt[*]
       2 str = vc
   )
   SET dqp_tab_pos = locateval(dqp_tab_loop,1,dqp_info->cnt,dqp_tab_name,dqp_info->qual[dqp_tab_loop]
    .table_name)
   IF (dqp_tab_pos=0)
    SET dqp_tab_pos = drc_get_meta_data(dqp_info,dqp_tab_name)
    IF (dqp_tab_pos=0)
     RETURN(1)
    ELSEIF ((dqp_tab_pos=- (1)))
     RETURN(- (1))
    ELSEIF ((dqp_tab_pos=- (2)))
     SET dqp_tab_pos = dqp_info->cnt
     SET dqp_r_ind = 0
    ENDIF
   ENDIF
   IF ((dqp_info->qual[dqp_tab_pos].r_exist_ind=0))
    SET dqp_r_ind = 0
   ENDIF
   IF (dqp_r_ind=1)
    SET dqp_query_tab = dqp_info->qual[dqp_tab_pos].r_table_name
   ELSE
    SET dqp_query_tab = dqp_tab_name
   ENDIF
   SET dqp_root_col = dqp_info->qual[dqp_tab_pos].root_column
   IF (dqp_root_col="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not find top level column for ",dqp_tab_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((dqp_info->qual[dqp_tab_pos].meaningful_cnt > 0))
    WHILE (dqp_done_ind=0)
      SET stat = alterlist(dqp_parse->stmt,200)
      SET dqp_parse->stmt[1].str = 'select into "NL:"'
      SET dqp_cnt = 2
      SET dqp_qual = 0
      FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
        IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].notnull_ind=0))
          IF (dqp_cnt > 2)
           SET dqp_parse->stmt[dqp_cnt].str = ", "
           SET dqp_cnt = (dqp_cnt+ 1)
          ENDIF
          SET dqp_parse->stmt[dqp_cnt].str = concat("n",trim(cnvtstring(dqp_col_loop)),
           " = nullind(r.",dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("VC", "C*")))
          IF (dqp_cnt > 2)
           SET dqp_parse->stmt[dqp_cnt].str = ", "
           SET dqp_cnt = (dqp_cnt+ 1)
          ENDIF
          SET dqp_parse->stmt[dqp_cnt].str = concat("ts",trim(cnvtstring(dqp_col_loop)),
           " = length(r.",dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
        ENDIF
      ENDFOR
      SET dqp_parse->stmt[dqp_cnt].str = concat(" from ",dqp_query_tab," r where ")
      SET dqp_cnt = (dqp_cnt+ 1)
      IF (dqp_r_ind=1)
       SET dqp_parse->stmt[dqp_cnt].str = " r.rdds_delete_ind = 0 and r.rdds_status_flag < 9000 and "
       SET dqp_cnt = (dqp_cnt+ 1)
      ENDIF
      SET dqp_parse->stmt[dqp_cnt].str = concat(" r.",dqp_root_col," = dqp_value ")
      SET dqp_cnt = (dqp_cnt+ 1)
      IF (dqp_tab_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
       SET dqp_parse->stmt[dqp_cnt].str = concat(" or (r.",dqp_tab_name,
        "_ID = dqp_value and (r.active_Ind = 1 or ",
        "(r.active_ind = 0 and r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))))")
       SET dqp_cnt = (dqp_cnt+ 1)
      ENDIF
      SET dqp_parse->stmt[dqp_cnt].str = " detail dqp_qual = dqp_qual + 1"
      SET dqp_cnt = (dqp_cnt+ 1)
      FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
        IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
         SET dqp_parse->stmt[dqp_cnt].str = concat(" dqp_map->col_cnt = dqp_map->col_cnt + 1",
          " stat = alterlist(dqp_map->col_qual, dqp_map->col_cnt) ")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].table_name = '",dqp_tab_name,"'")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].column_name = '",dqp_info->qual[dqp_tab_pos].
          col_qual[dqp_col_loop].column_name,"'")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = ",trim(cnvtstring(dqp_info->qual[
            dqp_tab_pos].col_qual[dqp_col_loop].meaningful_pos)))
         SET dqp_cnt = (dqp_cnt+ 1)
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].notnull_ind=0))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].null_ind = n",trim(cnvtstring(dqp_col_loop)))
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = r.",dqp_info->qual[dqp_tab_pos].
           col_qual[dqp_col_loop].column_name)
          SET dqp_cnt = (dqp_cnt+ 1)
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].t_space_cnt = ts",trim(cnvtstring(dqp_col_loop)),
           " - size(dqp_map->col_qual[dqp_map->col_cnt].column_value)")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = cnvtstring(r.",dqp_info->qual[
           dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type="F8"))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = cnvtstring(r.",dqp_info->qual[
           dqp_tab_pos].col_qual[dqp_col_loop].column_name,",20,3)")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = format(r.",dqp_info->qual[dqp_tab_pos
           ].col_qual[dqp_col_loop].column_name,",'DD-MMM-YYYY HH:MM:SS;;D')")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
        ENDIF
      ENDFOR
      SET dqp_parse->stmt[dqp_cnt].str = " with nocounter go"
      SET stat = alterlist(dqp_parse->stmt,dqp_cnt)
      EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DQP_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dqp_done_ind = 1
      ELSE
       IF (dqp_qual=0
        AND dqp_r_ind=1
        AND dqp_retry_ind=0)
        SET dqp_query_tab = dqp_tab_name
        SET dqp_retry_ind = 1
        SET dqp_r_ind = 0
        SET stat = alterlist(dqp_parse->stmt,0)
       ELSE
        SET dqp_done_ind = 1
       ENDIF
      ENDIF
    ENDWHILE
    IF ((dm_err->err_ind=1))
     RETURN(1)
    ENDIF
    IF (dqp_qual=0)
     FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
       IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
        SET dqp_map->col_cnt = (dqp_map->col_cnt+ 1)
        SET stat = alterlist(dqp_map->col_qual,dqp_map->col_cnt)
        SET dqp_map->col_qual[dqp_map->col_cnt].table_name = dqp_tab_name
        SET dqp_map->col_qual[dqp_map->col_cnt].column_name = dqp_info->qual[dqp_tab_pos].col_qual[
        dqp_col_loop].column_name
        SET dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = dqp_info->qual[dqp_tab_pos].col_qual[
        dqp_col_loop].meaningful_pos
        SET dqp_map->col_qual[dqp_map->col_cnt].column_value = "<ORPHAN VALUE>"
       ENDIF
     ENDFOR
    ENDIF
    IF (dqp_qual > 1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Multiple meaningful data sets were found for table ",dqp_tab_name,
      " and value ",trim(cnvtstring(dqp_value)))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    FOR (dqp_col_loop = 1 TO dqp_map->col_cnt)
     IF (size(dqp_map->col_qual[dqp_col_loop].column_value)=0)
      IF ((dqp_map->col_qual[dqp_col_loop].t_space_cnt > 0))
       SET dqp_map->col_qual[dqp_col_loop].column_value = "<SPACE>"
      ELSE
       SET dqp_map->col_qual[dqp_col_loop].column_value = "[NULL]"
      ENDIF
     ENDIF
     SET dqp_map->col_qual[dqp_col_loop].column_value = replace(dqp_map->col_qual[dqp_col_loop].
      column_value,char(0),"<CHAR(0)>",0)
    ENDFOR
   ELSE
    SET dqp_map->col_cnt = (dqp_map->col_cnt+ 1)
    SET stat = alterlist(dqp_map->col_qual,dqp_map->col_cnt)
    SET dqp_map->col_qual[dqp_map->col_cnt].table_name = dqp_tab_name
    SET dqp_map->col_qual[dqp_map->col_cnt].column_name = "NOMEAN"
    SET dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = 1
    SET dqp_map->col_qual[dqp_map->col_cnt].column_value =
    "<No meaningful data setup for this table.>"
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_batch(dgb_mstr,dgb_info,dgb_table,dgb_delete_ind)
   DECLARE dgb_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_tab_idx = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgb_md_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_list = vc WITH protect, noconstant("")
   FREE RECORD dgb_md
   RECORD dgb_md(
     1 cnt = i4
     1 qual[*]
       2 r_rowid = vc
       2 col_cnt = i4
       2 col_str = vc
       2 col_qual[*]
         3 column_name = vc
         3 value = vc
   )
   SET dgb_tab_idx = locateval(dgb_tab_loop,1,dgb_info->cnt,dgb_table,dgb_info->qual[dgb_tab_loop].
    table_name)
   SET stat = alterlist(dgb_mstr->diff_qual,0)
   SET dgb_mstr->diff_cnt = 0
   IF (((dgb_delete_ind=1) OR ((dgb_info->qual[dgb_tab_idx].merge_delete_ind=0)
    AND (dgb_info->qual[dgb_tab_idx].versioning_alg != "ALG5")
    AND (dgb_info->qual[dgb_tab_idx].current_state_ind=0))) )
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ELSEIF ((dgb_md->cnt > 100))
     SET dgb_col_idx = 100
    ELSE
     SET dgb_col_idx = dgb_md->cnt
    ENDIF
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_col_idx))
     SET c.status = "PROCESS"
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].current_state_ind=1))
    SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].current_state_grp_col,"'")
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].versioning_ind=1)
    AND (dgb_info->qual[dgb_tab_idx].versioning_alg="ALG5"))
    FOR (dgb_md_loop = 1 TO dgb_info->qual[dgb_tab_idx].col_cnt)
      IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].exception_flg=12))
       IF (dgb_col_list="")
        SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].column_name,
         "'")
       ELSE
        SET dgb_col_list = concat(dgb_col_list,",'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop]
         .column_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].merge_delete_ind=1))
    FOR (dgb_md_loop = 1 TO dgb_info->qual[dgb_tab_idx].col_cnt)
      IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].merge_delete_ind=1))
       IF (dgb_col_list="")
        SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].column_name,
         "'")
       ELSE
        SET dgb_col_list = concat(dgb_col_list,",'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop]
         .column_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   SET dgb_tab_idx = locateval(dgb_tab_loop,1,dgb_info->cnt,dgb_table,dgb_info->qual[dgb_tab_loop].
    table_name)
   SELECT INTO "NL:"
    rn = nullind(d.r_column_value), ln = nullind(d.l_column_value), rts = length(d.r_column_value),
    lts = length(d.l_column_value)
    FROM dm_refchg_comp_gttd d
    WHERE d.status="PROCESS"
    ORDER BY d.r_rowid, d.column_name
    HEAD d.r_rowid
     dgb_mstr->diff_cnt = (dgb_mstr->diff_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual,dgb_mstr->
      diff_cnt), dgb_mstr->table_name = dgb_table,
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].log_type = "NONE", dgb_mstr->diff_qual[dgb_mstr->
     diff_cnt].context = "NONE"
    DETAIL
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt = (dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
     col_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual,dgb_mstr->
      diff_qual[dgb_mstr->diff_cnt].col_cnt), dgb_mstr->diff_qual[dgb_mstr->diff_cnt].ptam_hash = d
     .r_ptam_hash_value,
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt
     ].column_name = d.column_name, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
     diff_qual[dgb_mstr->diff_cnt].col_cnt].r_null_ind = rn, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
     col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].l_null_ind = ln,
     dgb_col_idx = locateval(dgb_col_loop,1,dgb_info->qual[dgb_tab_idx].col_cnt,d.column_name,
      dgb_info->qual[dgb_tab_idx].col_qual[dgb_col_loop].column_name)
     IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_col_idx].parent_entity_col > " "))
      IF (d.r_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = substring(1,(findstring("::",d.r_column_value,1,0) - 1),d.r_column_value)
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = d.r_column_value
      ENDIF
      IF (d.l_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = substring(1,(findstring("::",d.l_column_value,1,0) - 1),d.l_column_value)
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = d.l_column_value
      ENDIF
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt = (dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual,dgb_mstr->
       diff_qual[dgb_mstr->diff_cnt].col_cnt), dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].column_name = dgb_info->qual[dgb_tab_idx].
      col_qual[dgb_col_idx].parent_entity_col,
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].r_null_ind = rn, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[
      dgb_mstr->diff_cnt].col_cnt].l_null_ind = ln
      IF (d.r_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = substring((findstring("::",d.r_column_value,1,0)+ 2),rts,d.r_column_value),
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_tscnt = (((rts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
        diff_qual[dgb_mstr->diff_cnt].col_cnt].r_value)) - 2) - size(dgb_mstr->diff_qual[dgb_mstr->
        diff_cnt].col_qual[(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt - 1)].r_value))
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = d.r_column_value
      ENDIF
      IF (d.l_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = substring((findstring("::",d.l_column_value,1,0)+ 2),lts,d.l_column_value),
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_tscnt = (((lts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
        diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value)) - 2) - size(dgb_mstr->diff_qual[dgb_mstr->
        diff_cnt].col_qual[(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt - 1)].l_value))
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = d.l_column_value
      ENDIF
     ELSE
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].r_value = d.r_column_value, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr
      ->diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value = d.l_column_value, dgb_mstr->diff_qual[
      dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].r_tscnt = (rts -
      size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value)),
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].l_tscnt = (lts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
       diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Loading batch data into MSTR_DATA")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (drlc_debug_flag > 0
    AND curqual > 0)
    SELECT
     *
     FROM dm_refchg_comp_gttd
     WHERE status="PROCESS"
     ORDER BY r_rowid, column_name
     WITH nocounter
    ;end select
    SET drlc_debug_flag = 0
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   DELETE  FROM dm_refchg_comp_gttd d
    WHERE d.status="PROCESS"
    WITH nocounter
   ;end delete
   IF (check_error("Removing data loaded into MSTR_DATA from DM_REFCHG_COMP_GTTD")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_load_report(dlr_mstr,dlr_info,dlr_temp,dlr_cur_pos,dlr_env_name,dlr_del_ind)
   DECLARE dlr_row_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_mcol_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dlr_mcol_pos = i4 WITH protect, noconstant(0)
   DECLARE dlr_mean_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_data_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_top_level_ind = i2 WITH protect, noconstant(0)
   DECLARE dlr_max_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlr_nomean = vc WITH protect, noconstant("<No meaningful data setup for this table.>")
   DECLARE dlr_size = i4 WITH protect, noconstant(0)
   SET dlr_size = size(dlr_temp->text_qual,5)
   IF (dlr_del_ind=1)
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
      IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
       SET dlr_size = (dlr_size+ 10000)
       SET stat = alterlist(dlr_temp->text_qual,dlr_size)
      ENDIF
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      IF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0))
       SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
       "<IDENT_STR>Data to be deleted: </IDENT_STR>"
      ELSE
       SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
       "<IDENT_STR>Data Set to be deleted: </IDENT_STR>"
      ENDIF
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0))
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
          SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
           dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
           dlr_row_loop].col_qual[dlr_col_loop].column_name)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_loop].l_mean_str),
           "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
           "</PK_COL>")
          IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
          dlr_cur_pos].col_qual[dlr_col_idx].column_name)
           AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
          dlr_cur_pos].table_name))
           IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
             table_name,"</INFO_COL></PK_INFO>")
           ELSE
            FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
              IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
               SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
                dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 l_mean_str),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[
                dlr_mean_loop].column_name,"</INFO_COL></PK_INFO>")
               FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
               l_level_cnt)
                SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
                SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                 encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                  l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                 dlr_row_loop].col_qual[dlr_mcol_pos].l_level_qual[dlr_data_loop].trans_str,
                 "</INFO_COL></PK_INFO>")
               ENDFOR
              ENDIF
            ENDFOR
           ENDIF
          ELSE
           IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
            FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
            l_level_cnt)
             SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
              encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
               l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
              dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,
              "</INFO_COL></PK_INFO>")
            ENDFOR
           ENDIF
          ENDIF
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
         ENDIF
        ELSE
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=1))
          SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
           dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
           dlr_row_loop].col_qual[dlr_col_loop].column_name)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
           "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
           "</PK_COL>")
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           l_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
    ENDFOR
   ELSEIF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0)
    AND (dlr_info->qual[dlr_cur_pos].versioning_alg != "ALG5")
    AND (dlr_info->qual[dlr_cur_pos].current_state_ind=0))
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str != "RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
       "<IDENT_STR>Data affected: </IDENT_STR>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>0</MD_IND>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</PK_COL>")
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
         dlr_cur_pos].col_qual[dlr_col_idx].column_name)
          AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
         dlr_cur_pos].table_name))
          IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
            encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
            table_name,"</INFO_COL></PK_INFO>")
          ELSE
           FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
             IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
              SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
               dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
               dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
              SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
              SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
               encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].l_mean_str
                ),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].
               column_name,"</INFO_COL></PK_INFO>")
              FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
              l_level_cnt)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_pos].l_level_qual[dlr_data_loop].trans_str,
                "</INFO_COL></PK_INFO>")
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
         ELSE
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           l_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
      "<CHANGE_TYPE><CHANGE_STR>Data values to be modified: </CHANGE_STR>"
      FOR (dlr_col_idx = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_cnt)
        IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str != dlr_mstr->
        diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_info->qual[dlr_cur_pos].col_cnt,dlr_mstr->
          diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,dlr_info->qual[dlr_cur_pos].
          col_qual[dlr_col_loop].column_name)
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_loop].column_name != dlr_info->qual[
         dlr_cur_pos].root_column))
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>0</SET_CNT>"
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_COL>",
           dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,
           "</CHANGE_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[
            dlr_col_idx].l_mean_str),"</OLD_VAL><NEW_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str),
           "</NEW_VAL>")
          SET dlr_max_cnt = greatest(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].
           l_level_cnt,dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt)
          FOR (dlr_data_loop = 1 TO dlr_max_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_cnt < dlr_data_loop)
            )
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
             "<CHANGE_INFO><OLD_COL></OLD_COL><OLD_VAL></OLD_VAL>"
            ELSE
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><OLD_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].
              trans_str,"</OLD_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].mean_str),"</OLD_VAL>")
            ENDIF
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt >= dlr_data_loop
            ))
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
              text_cnt].str,"<NEW_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].mean_str),"</NEW_VAL><NEW_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].
              trans_str,
              "</NEW_COL>")
            ENDIF
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
             text_cnt].str,"</CHANGE_INFO>")
          ENDFOR
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA></SET_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
     ENDIF
    ENDFOR
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
       "<IDENT_STR>Data to be inactivated: </IDENT_STR>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>0</MD_IND>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_mean_str),
          "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</PK_COL>")
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
         dlr_cur_pos].col_qual[dlr_col_idx].column_name)
          AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
         dlr_cur_pos].table_name))
          IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
            encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
            table_name,"</INFO_COL></PK_INFO>")
          ELSE
           FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
             IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
              SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
               dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
               dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
              SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
              SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
               encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].r_mean_str
                ),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].
               column_name,"</INFO_COL></PK_INFO>")
              FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
              r_level_cnt)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 r_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_pos].r_level_qual[dlr_data_loop].trans_str,
                "</INFO_COL></PK_INFO>")
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
         ELSE
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           r_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
     ENDIF
    ENDFOR
   ELSE
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
     "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
     encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
     "<IDENT_STR>Data Set affected: </IDENT_STR>")
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>1</MD_IND>"
    FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
      IF ((dlr_info->qual[dlr_cur_pos].current_state_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name=dlr_info->qual[dlr_cur_pos]
      .current_state_grp_col))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ELSEIF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].merge_delete_ind=1))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ELSEIF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg=12)
       AND (dlr_info->qual[dlr_cur_pos].versioning_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5"))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data affected: </CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str != "RDDS NO VAL")
      AND (dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].r_mean_str != "RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name != dlr_info->qual[
        dlr_cur_pos].current_state_grp_col)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          l_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      FOR (dlr_col_idx = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_cnt)
        IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str != dlr_mstr->
        diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str))
         IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
          SET dlr_size = (dlr_size+ 10000)
          SET stat = alterlist(dlr_temp->text_qual,dlr_size)
         ENDIF
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_info->qual[dlr_cur_pos].col_cnt,dlr_mstr->
          diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,dlr_info->qual[dlr_cur_pos].
          col_qual[dlr_col_loop].column_name)
         IF ((((dlr_info->qual[dlr_cur_pos].current_state_ind=0)) OR ((dlr_info->qual[dlr_cur_pos].
         current_state_ind=1)
          AND (dlr_info->qual[dlr_cur_pos].root_column != dlr_info->qual[dlr_cur_pos].col_qual[
         dlr_col_pos].column_name)
          AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
         col_qual[dlr_col_pos].column_name))) )
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>1</GRP_CNT>"
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<GROUP_DATA><OLD_COL>",dlr_mstr->
           diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,"</OLD_COL><OLD_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str),
           "</OLD_VAL><NEW_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str),
           "</NEW_VAL>")
          SET dlr_max_cnt = greatest(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].
           l_level_cnt,dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt)
          FOR (dlr_data_loop = 1 TO dlr_max_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_cnt < dlr_data_loop)
            )
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(
              "<GROUP_INFO><OLD_COL>-</OLD_COL><OLD_VAL>-</OLD_VAL>")
            ELSE
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<GROUP_INFO><OLD_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].
              trans_str,"</OLD_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].mean_str),"</OLD_VAL>")
            ENDIF
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt >= dlr_data_loop
            ))
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
              text_cnt].str,"<NEW_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].mean_str),"</NEW_VAL><NEW_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].
              trans_str,
              "</NEW_COL>")
            ENDIF
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
             text_cnt].str,"</GROUP_INFO>")
          ENDFOR
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</GROUP_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data to be added to set:</CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((((dlr_info->qual[dlr_cur_pos].merge_delete_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)) OR ((((dlr_info
        ->qual[dlr_cur_pos].versioning_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5")
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)) OR ((dlr_info->
        qual[dlr_cur_pos].current_state_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].current_state_grp_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name)
         AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name))) ))
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          r_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].r_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>0</GRP_CNT></SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data to be deleted from set:</CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].r_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((((dlr_info->qual[dlr_cur_pos].merge_delete_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)) OR ((((dlr_info
        ->qual[dlr_cur_pos].versioning_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5")
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)) OR ((dlr_info->
        qual[dlr_cur_pos].current_state_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].current_state_grp_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name)
         AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name))) ))
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          l_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>0</GRP_CNT></SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_log_type(dglt_mstr,dglt_target_id)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = dglt_mstr->diff_cnt),
     dm_chg_log dl
    PLAN (d
     WHERE (dglt_mstr->diff_qual[d.seq].ptam_hash > 0.0))
     JOIN (dl
     WHERE (dl.table_name=dglt_mstr->table_name)
      AND (dl.ptam_match_result=dglt_mstr->diff_qual[d.seq].ptam_hash)
      AND ((dl.target_env_id+ 0)=dglt_target_id))
    ORDER BY dl.updt_dt_tm
    DETAIL
     dglt_mstr->diff_qual[d.seq].log_type = dl.log_type, dglt_mstr->diff_qual[d.seq].context = dl
     .context_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_inserts(dgi_info,dgi_cur_pos,dgi_context)
   DECLARE dgi_pk_where = vc WITH protect, noconstant("")
   DECLARE dgi_col_list = vc WITH protect, noconstant("")
   DECLARE dgi_loop = i4 WITH protect, noconstant(0)
   DECLARE dgi_nullval = vc WITH protect, noconstant("")
   DECLARE dgi_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgi_ret_val = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_tab = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_loop = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_r_table = vc WITH protect, noconstant("")
   DECLARE dgi_par_col_list = vc WITH protect, noconstant("")
   DECLARE dgi_stmt_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dgi_stmt
   RECORD dgi_stmt(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD dgi_collist
   RECORD dgi_collist(
     1 cnt = i4
     1 list[*]
       2 col = vc
     1 parcnt = i4
     1 parlist[*]
       2 col = vc
   )
   SET dgi_pk_where = concat(" r.RDDS_DELETE_IND = 0 and r.rdds_status_flag < 9000")
   IF (dgi_context != char(42))
    SET dgi_pk_where = concat(dgi_pk_where," and (r.rdds_context_name = '",dgi_context,
     "' or r.rdds_context_name = patstring('",dgi_context,
     "::*') or r.rdds_context_name = patstring('*::",dgi_context,
     "') or r.rdds_context_name = patstring ('*::",dgi_context,"::*'))")
   ENDIF
   FOR (dgi_loop = 1 TO dgi_info->qual[dgi_cur_pos].col_cnt)
    IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("VC", "C*")))
     SET dgi_nullval = "'AbyZ12%$90'"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("I4", "I2")))
     SET dgi_nullval = "-123"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type="F8"))
     SET dgi_nullval = "-123.456"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("DQ8", "DM12")))
     SET dgi_nullval = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
    ENDIF
    IF ((dgi_info->qual[dgi_cur_pos].current_state_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].column_name=dgi_info->qual[dgi_cur_pos].
     current_state_grp_col))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].merge_delete_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].merge_delete_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1)
     AND (dgi_info->qual[dgi_cur_pos].versioning_alg="ALG5"))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].exception_flg=12))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1)
     AND (dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].unique_ident_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSE
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].pk_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF ((dgi_info->qual[dgi_cur_pos].current_state_ind=0))
    SET stat = alterlist(dgi_stmt->stmt,4)
    SET dgi_stmt->stmt[1].str = concat("select into 'NL:' cnt = count(*) from ",dgi_info->qual[
     dgi_cur_pos].r_table_name," r where ")
    SET dgi_stmt->stmt[2].str = concat(dgi_pk_where," and not exists(")
    SET dgi_stmt->stmt[3].str = "select 'x'"
    SET dgi_stmt->stmt[4].str = concat(" from ",dgi_info->qual[dgi_cur_pos].table_name," l where ")
    SET dgi_stmt_cnt = 4
    FOR (dgi_loop = 1 TO dgi_collist->cnt)
      SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
      SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
      IF (dgi_stmt_cnt=5)
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_collist->list[dgi_loop].col," = ",replace(
         dgi_collist->list[dgi_loop].col,"r.","l.",0))
      ELSE
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",dgi_collist->list[dgi_loop].col," = ",
        replace(dgi_collist->list[dgi_loop].col,"r.","l.",0))
      ENDIF
    ENDFOR
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str,")")
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
    IF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and (r.",dgi_info->qual[dgi_cur_pos].
       active_name," = 1")
      IF ((dgi_info->qual[dgi_cur_pos].effective_col_ind=1))
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str," or r.",
        dgi_info->qual[dgi_cur_pos].end_col_name," > cnvtdatetime(curdate,curtime3)")
      ENDIF
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str," )")
     ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG2", "ALG5")))
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and r.",dgi_info->qual[dgi_cur_pos].
       end_col_name," > cnvtdatetime(curdate,curtime3)")
     ENDIF
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
     SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = " detail dgi_ret_val = cnt with nocounter go"
    ELSE
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = " detail dgi_ret_val = cnt with nocounter go"
    ENDIF
   ELSE
    SET dgi_par_tab = locateval(dgi_par_loop,1,dgi_info->cnt,dgi_info->qual[dgi_cur_pos].
     current_state_parent,dgi_info->qual[dgi_par_loop].table_name)
    IF (dgi_par_tab=0)
     SET dgi_par_tab = drc_get_meta_data(dgi_info,dgi_info->qual[dgi_cur_pos].current_state_parent)
     IF (dgi_par_tab=0)
      RETURN(- (1))
     ELSEIF ((dgi_par_tab=- (1)))
      RETURN(- (2))
     ELSEIF ((dgi_par_tab=- (2)))
      SET dgi_par_tab = dgi_info->cnt
      SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].table_name
     ELSE
      SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].r_table_name
     ENDIF
    ELSE
     SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].r_table_name
    ENDIF
    IF ((((dgi_info->qual[dgi_par_tab].versioning_ind != 1)) OR ( NOT ((dgi_info->qual[dgi_par_tab].
    versioning_alg IN ("ALG1", "ALG3"))))) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("The current state table of ",dgi_info->qual[dgi_cur_pos].table_name,
      " with parent table of ",dgi_info->qual[dgi_cur_pos].current_state_parent,
      " is currently not supported")
     RETURN(- (1))
    ENDIF
    SET stat = alterlist(dgi_stmt->stmt,100)
    SET dgi_stmt->stmt[1].str = concat("select into 'NL:' cnt = count(*) from ",dgi_info->qual[
     dgi_cur_pos].r_table_name," r where ")
    SET dgi_stmt->stmt[2].str = dgi_pk_where
    SET dgi_stmt->stmt[3].str = " and exists (select 'x' "
    SET dgi_stmt->stmt[4].str = concat(" from ",dgi_par_r_table," r1 where ")
    IF (findstring("$R",dgi_par_r_table,0,0) > 0)
     SET dgi_stmt->stmt[4].str = concat(dgi_stmt->stmt[4].str,replace(dgi_pk_where,"r.","r1.",0),
      " and ")
    ENDIF
    SET dgi_stmt->stmt[5].str = concat(" r1.",dgi_info->qual[dgi_cur_pos].current_state_par_col,
     " = r.",dgi_info->qual[dgi_cur_pos].current_state_par_col," and ")
    SET dgi_stmt->stmt[6].str = concat(" (r1.",dgi_info->qual[dgi_par_tab].active_name," =  1")
    IF ((dgi_info->qual[dgi_par_tab].effective_col_ind=1))
     SET dgi_stmt->stmt[7].str = concat(" or (r1.",dgi_info->qual[dgi_par_tab].active_name,
      " = 0 and ","r1.",dgi_info->qual[dgi_par_tab].beg_col_name,
      " <= cnvtdatetime(curdate,curtime3)")
     SET dgi_stmt->stmt[8].str = concat(" and r1.",dgi_info->qual[dgi_par_tab].end_col_name,
      " >= cnvtdatetime(curdate,curtime3)")
     FOR (dgi_loop = 1 TO dgi_info->qual[dgi_par_tab].col_cnt)
       IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].unique_ident_ind=1))
        IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("VC", "C*")))
         SET dgi_nullval = "'AbyZ12%$90'"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("I4", "I2")))
         SET dgi_nullval = "-123"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type="F8"))
         SET dgi_nullval = "-123.456"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("DQ8", "DM12")))
         SET dgi_nullval = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
        ENDIF
        SET dgi_collist->parcnt = (dgi_collist->parcnt+ 1)
        SET stat = alterlist(dgi_collist->parlist,dgi_collist->parcnt)
        IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].notnull_ind=1))
         SET dgi_collist->parlist[dgi_collist->parcnt].col = concat("r1.",dgi_info->qual[dgi_par_tab]
          .col_qual[dgi_loop].column_name)
        ELSE
         SET dgi_collist->parlist[dgi_collist->parcnt].col = concat("nullval(","r1.",dgi_info->qual[
          dgi_par_tab].col_qual[dgi_loop].column_name,",",dgi_nullval,
          ")")
        ENDIF
       ENDIF
     ENDFOR
     SET dgi_stmt->stmt[9].str = " and exists (select 'x' from "
     SET dgi_stmt->stmt[10].str = concat(dgi_par_r_table," r2 where ")
     IF (findstring("$R",dgi_par_r_table,0,0) > 0)
      SET dgi_stmt->stmt[10].str = concat(dgi_stmt->stmt[10].str,replace(dgi_pk_where,"r.","r2.",0),
       " and ")
     ENDIF
     SET dgi_stmt_cnt = 11
     SET dgi_stmt->stmt[11].str = concat(" r2.",dgi_info->qual[dgi_par_tab].active_name," = 1")
     FOR (dgi_loop = 1 TO dgi_collist->parcnt)
      SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",dgi_collist->parlist[dgi_loop].col," = ",
       replace(dgi_collist->parlist[dgi_loop].col,"r1.","r2.",0))
     ENDFOR
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str,"))")
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    ELSE
     SET dgi_stmt_cnt = 7
    ENDIF
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = " )) "
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and not exists (select 'x' from ",dgi_info->qual[
     dgi_cur_pos].table_name," l")
    FOR (dgi_loop = 1 TO dgi_collist->cnt)
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
     IF (dgi_loop=1)
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" where ",replace(dgi_collist->list[dgi_loop].col,
        "r.","l.",0)," = ",dgi_collist->list[dgi_loop].col)
     ELSE
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",replace(dgi_collist->list[dgi_loop].col,
        "r.","l.",0)," = ",dgi_collist->list[dgi_loop].col)
     ENDIF
    ENDFOR
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = ") detail dgi_ret_val = cnt with nocounter go"
    SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
   ENDIF
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DGI_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(dgi_ret_val)
 END ;Subroutine
 SUBROUTINE drcc_log_error_info(dlei_table_name,dlei_proc,dlei_error,dlei_name)
   DECLARE dlei_ret_ind = i2 WITH protect, noconstant(0)
   SET dm_err->err_ind = 0
   FREE RECORD dlei_data
   RECORD dlei_data(
     1 text_cnt = i4
     1 text_qual[*]
       2 str = vc
   )
   SET dlei_data->text_cnt = 4
   SET stat = alterlist(dlei_data->text_qual,4)
   SET dlei_data->text_qual[1].str = concat("<TABLE_DATA><TABLE_NAME>",dlei_table_name,
    "</TABLE_NAME>")
   SET dlei_data->text_qual[2].str =
   "<ERROR_IND>1</ERROR_IND><ERROR_INFO>The report errored during the auditing of this table.</ERROR_INFO>"
   SET dlei_data->text_qual[3].str = concat("<ERROR_PROC>PROC=",encode_html_string(dlei_proc),
    "</ERROR_PROC>")
   SET dlei_data->text_qual[4].str = concat("<ERROR_MSG>ERROR=",encode_html_string(dlei_error),
    "</ERROR_MSG></TABLE_DATA>")
   SET dlei_ret_ind = drcc_create_report(dlei_name,dlei_data,0)
   RETURN(dlei_ret_ind)
 END ;Subroutine
 SUBROUTINE drcc_get_cut_cnt(dgcc_info,dgcc_cur_pos)
   DECLARE dgcc_return = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    y = count(*)
    FROM (parser(dgcc_info->qual[dgcc_cur_pos].r_table_name) r)
    WHERE r.rdds_status_flag < 9000
    DETAIL
     dgcc_return = y
    WITH nocounter
   ;end select
   IF (check_error("Getting count of uncutover rows")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(dgcc_return)
 END ;Subroutine
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc,
  i_type=vc) = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn,i_type)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,concat("Please enter a file name for ",i_type," (0 to exit): "))
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     SET accept = nopatcheck
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET accept = patcheck
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
 END ;Subroutine
 IF (validate(dm_batch_list_req->dblg_owner,"XYZ")="XYZ"
  AND validate(dm_batch_list_req->dblg_owner,"ABC")="ABC")
  FREE RECORD dm_batch_list_req
  RECORD dm_batch_list_req(
    1 dblg_owner = vc
    1 dblg_table = vc
    1 dblg_table_id = vc
    1 dblg_column = vc
    1 dblg_where = vc
    1 dblg_mode = vc
    1 dblg_num_cnt = i4
  )
 ENDIF
 IF (validate(dm_batch_list_rep->status_msg,"XYZ")="XYZ"
  AND validate(dm_batch_list_rep->status_msg,"ABC")="ABC")
  FREE RECORD dm_batch_list_rep
  RECORD dm_batch_list_rep(
    1 status = c1
    1 status_msg = vc
    1 list[*]
      2 batch_num = i4
      2 max_value = vc
  )
 ENDIF
 DECLARE drcc_meta_pos = i4 WITH protect, noconstant(0)
 DECLARE drcc_cur_pos = i4 WITH protect, noconstant(0)
 DECLARE drcc_col_loop = i4 WITH protect, noconstant(0)
 DECLARE drcc_stmt_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_and_ind = i4 WITH protect, noconstant(0)
 DECLARE drcc_mngfl_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_col_idx = i4 WITH protect, noconstant(0)
 DECLARE drcc_ret_ind = i2 WITH protect, noconstant(0)
 DECLARE drcc_pename_idx = i4 WITH protect, noconstant(0)
 DECLARE drcc_perm_mngfl = i4 WITH protect, noconstant(0)
 DECLARE drcc_done_ind = i2 WITH protect, noconstant(0)
 DECLARE drcc_env_name = vc WITH protect, noconstant("")
 DECLARE drcc_target_id = f8 WITH protect, noconstant(0.0)
 DECLARE drcc_ins_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_upd_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_del_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_cut_cnt = i4 WITH protect, noconstant(0)
 DECLARE drcc_done_batch = i4 WITH protect, noconstant(0)
 DECLARE drcc_batch_pos = f8 WITH protect, noconstant(0.0)
 DECLARE drcc_batch_loop = i4 WITH protect, noconstant(0)
 DECLARE drcc_cur_batch = f8 WITH protect, noconstant(0.0)
 DECLARE drcc_prev_debug = i4 WITH protect, noconstant(0)
 DECLARE evaluate_pe_name() = c255
 DECLARE length() = i4
 FREE RECORD mstr_data
 RECORD mstr_data(
   1 diff_cnt = i4
   1 table_name = vc
   1 diff_qual[*]
     2 col_cnt = i4
     2 log_type = vc
     2 context = vc
     2 ptam_hash = f8
     2 col_qual[*]
       3 column_name = vc
       3 r_value = vc
       3 l_value = vc
       3 r_null_ind = i2
       3 l_null_ind = i2
       3 r_tscnt = i4
       3 l_tscnt = i4
       3 r_mean_str = vc
       3 r_trans_str = vc
       3 r_level_cnt = i4
       3 r_level_qual[*]
         4 mean_str = vc
         4 trans_str = vc
         4 level = i4
       3 l_mean_str = vc
       3 l_trans_str = vc
       3 l_level_cnt = i4
       3 l_level_qual[*]
         4 mean_str = vc
         4 trans_str = vc
         4 level = i4
 )
 FREE RECORD drcc_batch
 RECORD drcc_batch(
   1 cnt = i4
   1 qual[*]
     2 batch_str = vc
     2 cnt = i4
 )
 SET dm_err->eproc = "Starting dm_rmc_comp_child"
 IF (validate(reply->status,"G")="G"
  AND validate(reply->status,"D")="D")
  FREE RECORD reply
  RECORD reply(
    1 status = c1
    1 status_msg = vc
    1 text_cnt = i4
    1 text_qual[*]
      2 str = vc
  )
 ENDIF
 SET reply->status = ""
 IF (validate(request->table_name,"XYZ")="XYZ"
  AND validate(request->table_name,"ABC")="ABC")
  FREE RECORD request
  RECORD request(
    1 table_name = vc
    1 context_name = vc
  )
  IF (((reflect(parameter(1,0)) != "C*") OR (reflect(parameter(2,0)) != "C*")) )
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Expected syntax: dm_rmc_comp_child <context_name>, <Table Name>"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_child
  ELSE
   SET request->context_name =  $1
   SET request->table_name =  $2
  ENDIF
 ENDIF
 IF ((validate(drcc_batch_size,- (102))=- (102))
  AND (validate(drcc_batch_size,- (43))=- (43)))
  DECLARE drcc_batch_size = f8 WITH protect, noconstant(10000.0)
 ENDIF
 IF ((validate(drlc_debug_flag,- (102))=- (102))
  AND (validate(drlc_debug_flag,- (43))=- (43)))
  DECLARE drlc_debug_flag = i4 WITH protect, noconstant(0)
 ENDIF
 SET drcc_prev_debug = drlc_debug_flag
 SET dm_err->eproc = "Gather meta-data for table"
 SET drcc_meta_pos = drc_get_meta_data(drc_tab_info,request->table_name)
 IF (drcc_meta_pos=0)
  GO TO exit_child
 ELSEIF ((drcc_meta_pos=- (1)))
  SET drcc_cur_pos = drc_tab_info->cnt
 ELSEIF ((drcc_meta_pos=- (2)))
  GO TO exit_child
 ELSE
  SET drcc_cur_pos = drcc_meta_pos
 ENDIF
 SET dm_err->eproc = "Gather environment information"
 SELECT INTO "NL:"
  FROM dm_info d,
   dm_environment de
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
   AND de.environment_id=d.info_number
  DETAIL
   drcc_env_name = de.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_child
 ENDIF
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET stat = alterlist(reply->text_qual,100000)
 SET reply->text_qual[reply->text_cnt].str = concat("<TABLE_DATA><TABLE_NAME>",request->table_name,
  " - ",drc_tab_info->qual[drcc_cur_pos].r_table_name,"</TABLE_NAME>")
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = "<ERROR_IND>0</ERROR_IND>"
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = "<DEFINING>"
 FOR (drcc_diff_loop = 1 TO drc_tab_info->qual[drcc_meta_pos].col_cnt)
   IF ((drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].defining_att_ind >= 1))
    IF ((reply->text_qual[reply->text_cnt].str="<DEFINING>"))
     SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,
      drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].column_name)
    ELSE
     SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,", ",
      drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].column_name)
    ENDIF
   ENDIF
 ENDFOR
 SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,
  "</DEFINING>")
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = "<NONDEFINING>"
 FOR (drcc_diff_loop = 1 TO drc_tab_info->qual[drcc_meta_pos].col_cnt)
   IF ((drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].defining_att_ind=0))
    IF ((reply->text_qual[reply->text_cnt].str="<NONDEFINING>"))
     SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,
      drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].column_name)
    ELSE
     SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,", ",
      drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_diff_loop].column_name)
    ENDIF
   ENDIF
 ENDFOR
 SET reply->text_qual[reply->text_cnt].str = concat(reply->text_qual[reply->text_cnt].str,
  "</NONDEFINING>")
 SELECT INTO "NL:"
  FROM (parser(drc_tab_info->qual[drcc_meta_pos].r_table_name) d)
  WHERE rdds_status_flag < 9000
  DETAIL
   drcc_target_id = d.rdds_source_env_id
  WITH nocounter, maxqual(d,1)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_child
 ENDIF
 IF (curqual=0)
  GO TO exit_child
 ENDIF
 SET mstr_data->table_name = request->table_name
 IF ((drc_tab_info->qual[drcc_meta_pos].batch_flag=1))
  CALL parser(concat('select into "NL:" d.',drc_tab_info->qual[drcc_meta_pos].batch_column,
    ", cnt = count(*) from ",drc_tab_info->qual[drcc_meta_pos].r_table_name," d "),0)
  CALL parser(" where d.rdds_delete_ind = 0 and d.rdds_status_flag < 9000 ",0)
  IF ((request->context_name != char(42)))
   CALL parser(concat(" and (d.rdds_context_name = '",request->context_name,
     "' or d.rdds_context_name = patstring('",request->context_name,
     "::*') or d.rdds_context_name = patstring('*::",
     request->context_name,"') or d.rdds_context_name = patstring ('*::",request->context_name,
     "::*'))"),0)
  ENDIF
  CALL parser(concat("group by d.",drc_tab_info->qual[drcc_meta_pos].batch_column," order by cnt "),0
   )
  CALL parser(concat(" detail if (drcc_batch->cnt = 0) drcc_batch->cnt = drcc_batch->cnt + 1 ",
    " stat = alterlist(drcc_batch->qual, drcc_batch->cnt) endif"),0)
  CALL parser(" if (drcc_batch->qual[drcc_batch->cnt].batch_str <= ' ')",0)
  CALL parser(concat(" drcc_batch->qual[drcc_batch->cnt].batch_str =concat('<suffix>.",drc_tab_info->
    qual[drcc_meta_pos].batch_column," in (',trim(cnvtstring(d.",drc_tab_info->qual[drcc_meta_pos].
    batch_column,",20)), '.0')"),0)
  CALL parser(" drcc_batch->qual[drcc_batch->cnt].cnt = cnt",0)
  CALL parser(" elseif (drcc_batch->qual[drcc_batch->cnt].cnt + cnt < drcc_batch_size) ",0)
  CALL parser(" drcc_batch->qual[drcc_batch->cnt].cnt = drcc_batch->qual[drcc_batch->cnt].cnt + cnt",
   0)
  CALL parser(concat(
    " drcc_batch->qual[drcc_batch->cnt].batch_str =concat(drcc_batch->qual[drcc_batch->cnt].batch_str, ",
    "', ',trim(cnvtstring(d.",drc_tab_info->qual[drcc_meta_pos].batch_column,",20)), '.0')"),0)
  CALL parser(" else ",0)
  CALL parser(concat(
    " drcc_batch->qual[drcc_batch->cnt].batch_str =concat(drcc_batch->qual[drcc_batch->cnt].batch_str, ",
    "')')"),0)
  CALL parser(
   " drcc_batch->cnt = drcc_batch->cnt + 1 stat = alterlist(drcc_batch->qual, drcc_batch->cnt) ",0)
  CALL parser(" drcc_batch->qual[drcc_batch->cnt].cnt = cnt",0)
  CALL parser(concat(" drcc_batch->qual[drcc_batch->cnt].batch_str =concat('<suffix>.",drc_tab_info->
    qual[drcc_meta_pos].batch_column," in (',trim(cnvtstring(d.",drc_tab_info->qual[drcc_meta_pos].
    batch_column,",20)), '.0')"),0)
  CALL parser(" endif with nocounter go",1)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_child
  ENDIF
  IF (curqual > 0)
   SET drcc_batch->qual[drcc_batch->cnt].batch_str = concat(drcc_batch->qual[drcc_batch->cnt].
    batch_str,")")
   SET drcc_batch_loop = locateval(drcc_batch_loop,1,drc_tab_info->qual[drcc_meta_pos].col_cnt,
    drc_tab_info->qual[drcc_meta_pos].batch_column,drc_tab_info->qual[drcc_meta_pos].col_qual[
    drcc_batch_loop].column_name)
   IF ((drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_batch_loop].notnull_ind=0))
    SET drcc_batch->cnt = (drcc_batch->cnt+ 1)
    SET stat = alterlist(drcc_batch->qual,drcc_batch->cnt)
    SET drcc_batch->qual[drcc_batch->cnt].batch_str = concat("<suffix>.",drc_tab_info->qual[
     drcc_meta_pos].batch_column," is null")
   ENDIF
  ELSE
   SET drc_tab_info->qual[drcc_meta_pos].batch_flag = 0
  ENDIF
 ELSEIF ((drc_tab_info->qual[drcc_meta_pos].batch_flag=2))
  SET drcc_batch->cnt = 27
  SET stat = alterlist(drcc_batch->qual,27)
  SET drcc_batch->qual[1].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"<= CHR(0)")
  SET drcc_batch->qual[2].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(0) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column," <= CHR(10)"
   )
  SET drcc_batch->qual[3].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(10) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(20)")
  SET drcc_batch->qual[4].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(20) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(30)")
  SET drcc_batch->qual[5].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(30) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(40)")
  SET drcc_batch->qual[6].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(40) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(50)")
  SET drcc_batch->qual[7].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(50) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(60)")
  SET drcc_batch->qual[8].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(60) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(70)")
  SET drcc_batch->qual[9].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(70) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(80)")
  SET drcc_batch->qual[10].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(80) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(90)")
  SET drcc_batch->qual[11].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(90) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(100)")
  SET drcc_batch->qual[12].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(100) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(110)")
  SET drcc_batch->qual[13].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(110) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(120)")
  SET drcc_batch->qual[14].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(120) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(130)")
  SET drcc_batch->qual[15].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(130) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(140)")
  SET drcc_batch->qual[16].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(140) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(150)")
  SET drcc_batch->qual[17].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(150) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(160)")
  SET drcc_batch->qual[18].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(160) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(170)")
  SET drcc_batch->qual[19].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(170) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(180)")
  SET drcc_batch->qual[20].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(180) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(190)")
  SET drcc_batch->qual[21].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(190) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(200)")
  SET drcc_batch->qual[22].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(200) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(210)")
  SET drcc_batch->qual[23].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(210) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(220)")
  SET drcc_batch->qual[24].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(220) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(230)")
  SET drcc_batch->qual[25].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(230) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(240)")
  SET drcc_batch->qual[26].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(240) and <suffix>.",drc_tab_info->qual[drcc_meta_pos].batch_column,
   " <= CHR(250)")
  SET drcc_batch->qual[27].batch_str = concat("<suffix>.",drc_tab_info->qual[drcc_meta_pos].
   batch_column,"> CHR(250)")
  SET drcc_batch_loop = locateval(drcc_batch_loop,1,drc_tab_info->qual[drcc_meta_pos].col_cnt,
   drc_tab_info->qual[drcc_meta_pos].batch_column,drc_tab_info->qual[drcc_meta_pos].col_qual[
   drcc_batch_loop].column_name)
  IF ((drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_batch_loop].notnull_ind=0))
   SET drcc_batch->cnt = (drcc_batch->cnt+ 1)
   SET stat = alterlist(drcc_batch->qual,drcc_batch->cnt)
   SET drcc_batch->qual[drcc_batch->cnt].batch_str = concat("<suffix>.",drc_tab_info->qual[
    drcc_meta_pos].batch_column," is null")
  ENDIF
 ELSEIF ((drc_tab_info->qual[drcc_meta_pos].batch_flag=3))
  CALL parser(concat('select into "NL:" cnt = count(d.',drc_tab_info->qual[drcc_meta_pos].
    batch_column,") from ",drc_tab_info->qual[drcc_meta_pos].r_table_name," d "),0)
  CALL parser(" where d.rdds_delete_ind = 0 and d.rdds_status_flag < 9000 ",0)
  IF ((request->context_name != char(42)))
   CALL parser(concat(" and (rdds_context_name = '",request->context_name,
     "' or rdds_context_name = patstring('",request->context_name,
     "::*') or rdds_context_name = patstring('*::",
     request->context_name,"') or rdds_context_name = patstring ('*::",request->context_name,"::*'))"
     ),0)
  ENDIF
  CALL parser(" detail drcc_batch_pos = cnt with nocounter go",1)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_child
  ENDIF
  IF (drcc_batch_pos <= drcc_batch_size)
   SET drc_tab_info->qual[drcc_meta_pos].batch_flag = 0
  ELSE
   SET drcc_batch_pos = ceil((drcc_batch_pos/ drcc_batch_size))
   SET dm_batch_list_req->dblg_owner = "V500"
   SET dm_batch_list_req->dblg_table = drc_tab_info->qual[drcc_meta_pos].r_table_name
   SET dm_batch_list_req->dblg_column = drc_tab_info->qual[drcc_meta_pos].batch_column
   SET dm_batch_list_req->dblg_where = "where rdds_delete_ind = 0 and rdds_status_flag < 9000"
   IF ((request->context_name != char(42)))
    SET dm_batch_list_req->dblg_where = concat(dm_batch_list_req->dblg_where,
     " and (rdds_context_name = '",request->context_name,"' or rdds_context_name like '",request->
     context_name,
     "::%' or rdds_context_name like '%::",request->context_name,
     "' or rdds_context_name like '%::",request->context_name,"::%')")
   ENDIF
   SET dm_batch_list_req->dblg_mode = "BATCH"
   SET dm_batch_list_req->dblg_num_cnt = cnvtint(drcc_batch_pos)
   EXECUTE dm_get_batch_list
   IF ((dm_batch_list_rep->status="F"))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_child
   ENDIF
   SET stat = alterlist(drcc_batch->qual,cnvtint(drcc_batch_pos))
   SET drcc_batch->cnt = cnvtint(drcc_batch_pos)
   FOR (drcc_batch_loop = 1 TO drcc_batch->cnt)
     IF (drcc_batch_loop=1)
      SET drcc_batch->qual[drcc_batch_loop].batch_str = concat("<suffix>.",drc_tab_info->qual[
       drcc_meta_pos].batch_column," <= ",dm_batch_list_rep->list[drcc_batch_loop].max_value,".0")
     ELSE
      SET drcc_batch->qual[drcc_batch_loop].batch_str = concat("<suffix>.",drc_tab_info->qual[
       drcc_meta_pos].batch_column," > ",dm_batch_list_rep->list[(drcc_batch_loop - 1)].max_value,
       ".0 and <suffix>.",
       drc_tab_info->qual[drcc_meta_pos].batch_column," <= ",dm_batch_list_rep->list[drcc_batch_loop]
       .max_value,".0")
     ENDIF
   ENDFOR
   SET drcc_batch_loop = locateval(drcc_batch_loop,1,drc_tab_info->qual[drcc_meta_pos].col_cnt,
    drc_tab_info->qual[drcc_meta_pos].batch_column,drc_tab_info->qual[drcc_meta_pos].col_qual[
    drcc_batch_loop].column_name)
   IF ((drc_tab_info->qual[drcc_meta_pos].col_qual[drcc_batch_loop].notnull_ind=0))
    SET drcc_batch->cnt = (drcc_batch->cnt+ 1)
    SET stat = alterlist(drcc_batch->qual,drcc_batch->cnt)
    SET drcc_batch->qual[drcc_batch->cnt].batch_str = concat("<suffix>.",drc_tab_info->qual[
     drcc_meta_pos].batch_column," is null")
   ENDIF
  ENDIF
 ENDIF
 SET drcc_ins_cnt = drcc_get_inserts(drc_tab_info,drcc_cur_pos,request->context_name)
 IF ((drcc_ins_cnt=- (1)))
  SET dm_err->err_ind = 1
  GO TO exit_child
 ELSEIF ((drcc_ins_cnt=- (2)))
  SET reply->status = "Z"
  SET reply->status_msg = "A commit occurred, must re-start table"
  GO TO exit_child
 ENDIF
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = concat("<INSERT_STATS># of Inserts: ",trim(cnvtstring(
    drcc_ins_cnt)),"</INSERT_STATS>")
 SET drcc_cut_cnt = drcc_get_cut_cnt(drc_tab_info,drcc_cur_pos)
 IF ((drcc_cut_cnt=- (1)))
  SET dm_err->err_ind = 1
  GO TO exit_child
 ENDIF
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = "<UPDATE_INFO>"
 SET drcc_batch_loop = 1
 IF ((drcc_batch->cnt=0))
  SET drcc_batch->cnt = 1
  SET stat = alterlist(drcc_batch->qual,1)
  SET drcc_batch->qual[1].batch_str = " "
 ENDIF
 IF (drlc_debug_flag > 0)
  SELECT INTO "dm_rmc_r_live_debug.txt"
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    "Start of Table: ", col + 1, mstr_data->table_name,
    row + 1
   WITH nocounter, maxrow = 1, maxcol = 4000,
    format = variable, formfeed = none, append
  ;end select
 ENDIF
 WHILE (drcc_done_batch=0)
   SET dm_err->eproc = "Load non-delete data into global temp table"
   IF ((drcc_batch->cnt > 1)
    AND mod(drcc_batch_loop,10)=0)
    SET dm_err->eproc = concat("Starting batch ",trim(cnvtstring(drcc_batch_loop))," of ",trim(
      cnvtstring(drcc_batch->cnt)))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ENDIF
   SET drcc_ret_ind = drcc_find_rows(drc_tab_info,mstr_data->table_name,request->context_name,0,
    drcc_batch->qual[drcc_batch_loop].batch_str)
   SET drlc_debug_flag = 0
   IF (drcc_ret_ind=1)
    GO TO exit_child
   ELSEIF ((drcc_ret_ind=- (1)))
    SET reply->status = "Z"
    SET reply->status_msg = "A commit occurred, must re-start table"
    GO TO exit_child
   ENDIF
   IF (drcc_batch_loop=1)
    SET drlc_debug_flag = drcc_prev_debug
   ENDIF
   WHILE (drcc_done_ind=0)
     SET dm_err->eproc = "Gather batch of data to compare"
     SET drcc_ret_ind = drcc_get_batch(mstr_data,drc_tab_info,drc_tab_info->qual[drcc_cur_pos].
      table_name,0)
     IF (drcc_ret_ind=1)
      SET drcc_done_ind = 1
      SET drcc_done_batch = 1
     ELSEIF ((mstr_data->diff_cnt=0))
      SET drcc_done_ind = 1
     ELSE
      SET drcc_upd_cnt = (drcc_upd_cnt+ mstr_data->diff_cnt)
      SET dm_err->eproc = "Get meaningful column data for all ID and CD values"
      FOR (drcc_row_loop = 1 TO mstr_data->diff_cnt)
        FOR (drcc_diff_loop = 1 TO mstr_data->diff_qual[drcc_row_loop].col_cnt)
         SET drcc_ret_ind = drcc_get_meaningful(mstr_data,drc_tab_info,drcc_row_loop,drcc_diff_loop,
          drcc_cur_pos)
         IF (drcc_ret_ind=1)
          SET drcc_done_ind = 1
          SET drcc_diff_loop = mstr_data->diff_qual[drcc_row_loop].col_cnt
          SET drcc_row_loop = mstr_data->diff_cnt
          SET drcc_done_batch = 1
         ELSEIF ((drcc_ret_ind=- (1)))
          SET reply->status = "Z"
          SET reply->status_msg = "A commit occurred, must re-start table"
          SET drcc_done_ind = 1
          SET drcc_diff_loop = mstr_data->diff_qual[drcc_row_loop].col_cnt
          SET drcc_row_loop = mstr_data->diff_cnt
          SET drcc_done_batch = 1
         ENDIF
        ENDFOR
      ENDFOR
      SET dm_err->eproc = "Gather LOG_TYPE of all rows with differences"
      IF (drcc_done_ind=0)
       SET drcc_ret_ind = drcc_get_log_type(mstr_data,drcc_target_id)
       IF (drcc_ret_ind=1)
        SET drcc_done_ind = 1
        SET drcc_done_batch = 1
       ENDIF
      ENDIF
      SET dm_err->eproc = "Fill out reply with report data"
      IF (drcc_done_ind=0)
       SET drcc_ret_ind = drcc_load_report(mstr_data,drc_tab_info,reply,drcc_cur_pos,drcc_env_name,
        0)
       IF (drcc_ret_ind=1)
        SET drcc_done_ind = 1
        SET drcc_done_batch = 1
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   SET drcc_done_ind = 0
   SET drcc_batch_loop = (drcc_batch_loop+ 1)
   IF ((drcc_batch_loop > drcc_batch->cnt))
    SET drcc_done_batch = 1
   ENDIF
 ENDWHILE
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = concat("<UPDATE_STATS># of Updates: ",trim(cnvtstring(
    drcc_upd_cnt)),"</UPDATE_STATS><UPDATE_CNT>",trim(cnvtstring(drcc_upd_cnt)),
  "</UPDATE_CNT></UPDATE_INFO>")
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = "<DELETE_INFO>"
 SET dm_err->eproc = "Load delete data into global temp table"
 CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
 SET drlc_debug_flag = drcc_prev_debug
 SET drcc_ret_ind = drcc_find_rows(drc_tab_info,mstr_data->table_name,request->context_name,1," ")
 IF (drcc_ret_ind=1)
  GO TO exit_child
 ENDIF
 SET drcc_done_ind = 0
 WHILE (drcc_done_ind=0)
   SET dm_err->eproc = "Gather batch of data to compare"
   SET drcc_ret_ind = drcc_get_batch(mstr_data,drc_tab_info,drc_tab_info->qual[drcc_cur_pos].
    table_name,1)
   IF (drcc_ret_ind=1)
    SET drcc_done_ind = 1
   ELSEIF ((mstr_data->diff_cnt=0))
    SET drcc_done_ind = 1
   ELSE
    SET drcc_del_cnt = (drcc_del_cnt+ mstr_data->diff_cnt)
    SET dm_err->eproc = "Get meaningful column data for all ID and CD values"
    FOR (drcc_row_loop = 1 TO mstr_data->diff_cnt)
      FOR (drcc_diff_loop = 1 TO mstr_data->diff_qual[drcc_row_loop].col_cnt)
       SET drcc_ret_ind = drcc_get_meaningful(mstr_data,drc_tab_info,drcc_row_loop,drcc_diff_loop,
        drcc_cur_pos)
       IF (drcc_ret_ind=1)
        SET drcc_done_ind = 1
        SET drcc_diff_loop = mstr_data->diff_qual[drcc_row_loop].col_cnt
        SET drcc_row_loop = mstr_data->diff_cnt
       ELSEIF ((drcc_ret_ind=- (1)))
        SET reply->status = "Z"
        SET reply->status_msg = "A commit occurred, must re-start table"
       ENDIF
      ENDFOR
    ENDFOR
    SET dm_err->eproc = "Gather LOG_TYPE of all rows with differences"
    IF (drcc_done_ind=0)
     SET drcc_ret_ind = drcc_get_log_type(mstr_data,drcc_target_id)
     IF (drcc_ret_ind=1)
      SET drcc_done_ind = 1
     ENDIF
    ENDIF
    SET dm_err->eproc = "Fill out reply with report data"
    IF (drcc_done_ind=0)
     SET drcc_ret_ind = drcc_load_report(mstr_data,drc_tab_info,reply,drcc_cur_pos,drcc_env_name,
      1)
     IF (drcc_ret_ind=1)
      SET drcc_done_ind = 1
     ENDIF
    ENDIF
   ENDIF
 ENDWHILE
 SET reply->text_cnt = (reply->text_cnt+ 1)
 SET reply->text_qual[reply->text_cnt].str = concat("<DELETE_STATS># of Deletes: ",trim(cnvtstring(
    drcc_del_cnt)),"</DELETE_STATS><DELETE_CNT>",trim(cnvtstring(drcc_del_cnt)),
  "</DELETE_CNT></DELETE_INFO>")
#exit_child
 SET drlc_debug_flag = drcc_prev_debug
 IF ((dm_err->err_ind=1))
  SET reply->status = "F"
  SET reply->status_msg = dm_err->emsg
 ELSEIF ((reply->status != "Z"))
  SET reply->status = "S"
  SET reply->status_msg = "The comparison report completed without error"
  IF ((reply->text_cnt > 0))
   SET reply->text_cnt = (reply->text_cnt+ 1)
   SET reply->text_qual[reply->text_cnt].str = concat("<TABLE_STATS># of Inserts: ",trim(cnvtstring(
      drcc_ins_cnt)),", # of Updates: ",trim(cnvtstring(drcc_upd_cnt)),", # of Deletes: ",
    trim(cnvtstring(drcc_del_cnt)),", # of Row to be Cutover: ",trim(cnvtstring(drcc_cut_cnt)),
    "</TABLE_STATS></TABLE_DATA>")
  ENDIF
 ENDIF
 ROLLBACK
END GO
