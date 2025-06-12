CREATE PROGRAM bsc_updt_med_admin_err_spcchk:dba
 DECLARE drs_tblcnt = i4 WITH protect, noconstant(0)
 IF ((validate(drs_spcchk_data->tbl_cnt,- (1))=- (1))
  AND (validate(drs_spcchk_data->tbl_cnt,- (2))=- (2)))
  FREE SET drs_spcchk_data
  RECORD drs_spcchk_data(
    1 set_large_data = i2
    1 tbl_cnt = i4
    1 qual[*]
      2 table_name = vc
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 updt_col_cnt = i4
      2 update_cols[*]
        3 column_name = vc
        3 update_row_cnt = f8
  )
 ENDIF
 IF ((drs_spcchk_data->tbl_cnt > 0))
  FOR (drs_tblcnt = 1 TO drs_spcchk_data->tbl_cnt)
   SET drs_spcchk_data->qual[drs_tblcnt].updt_col_cnt = 0
   SET stat = alterlist(drs_spcchk_data->qual[drs_tblcnt].update_cols,drs_spcchk_data->qual[
    drs_tblcnt].updt_col_cnt)
  ENDFOR
  SET drs_spcchk_data->tbl_cnt = 0
  SET stat = alterlist(drs_spcchk_data->qual,0)
 ENDIF
 IF ((validate(drs_spcchk_readme_data->orig_readme_id,- (1.00))=- (1.00))
  AND (validate(drs_spcchk_readme_data->orig_readme_id,- (2.00))=- (2.00)))
  FREE RECORD drs_spcchk_readme_data
  RECORD drs_spcchk_readme_data(
    1 orig_readme_id = f8
    1 orig_readme_execution = vc
    1 orig_readme_instance = i4
  )
 ENDIF
 DECLARE ml_table_rowcnt = i4 WITH protect, noconstant(0)
 DECLARE ms_process_name = vc WITH protect, noconstant("")
 DECLARE ms_table_name = vc WITH protect, noconstant("")
 DECLARE ms_column_name = vc WITH protect, noconstant("")
 DECLARE ms_operation_init = vc WITH protect, noconstant("")
 DECLARE ml_counter = i4 WITH protect, noconstant(0)
 DECLARE gf_fudge_factor = f8 WITH protect, noconstant(0.0)
 DECLARE mn_prev_run_ind = i2 WITH protect, noconstant(0)
 FREE RECORD mr_table
 RECORD mr_table(
   1 l_tlst_cnt = i4
   1 tlst[*]
     2 s_table_name = vc
     2 n_target_ind = i2
     2 l_clst_cnt = i4
     2 clst[*]
       3 s_column_name = vc
       3 n_target_ind = i2
 ) WITH protect
 DECLARE sbr_ccl_check(pl_tlst_cnt=i4) = i2
 DECLARE sbr_rdbms_check(pl_tlst_cnt=i4) = i2
 DECLARE sbr_add_table(ps_tbl_name=vc,pn_tgt_ind=i2) = null
 DECLARE sbr_add_column(ps_column_name=vc,pn_tgt_ind=i2) = null
 SET gf_fudge_factor = 1.20
 SET ms_process_name = "UPDATE ADMIN EVENT - ERROR_ID"
 SET ms_operation_init = "U"
 CALL sbr_add_table("MED_ADMIN_MED_ERROR",1)
 CALL sbr_add_column("TEMPLATE_ORDER_ID",1)
 CALL sbr_add_column("NEEDS_VERIFY_FLAG",1)
 CALL sbr_add_column("VERIFIED_PRSNL_ID",1)
 CALL sbr_add_column("VERIFICATION_DT_TM",1)
 CALL sbr_add_column("VERIFICATION_TZ",1)
 CALL sbr_add_column("ACTION_SEQUENCE",0)
 CALL sbr_add_column("ADMIN_DT_TM",0)
 IF (validate(drs_spcchk_readme_data->orig_readme_id,0) != 0)
  SELECT INTO "nl:"
   FROM dm_ocd_log dol
   PLAN (dol
    WHERE dol.project_type="README"
     AND dol.project_name=cnvtstring(drs_spcchk_readme_data->orig_readme_id)
     AND (dol.project_instance=drs_spcchk_readme_data->orig_readme_instance)
     AND dol.status="SUCCESS"
     AND (dol.environment_id=
    (SELECT
     di.info_number
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID")))
   HEAD REPORT
    mn_prev_run_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_prev_run_ind=1)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain=ms_process_name
    AND di.info_char="SUCCESS"
   HEAD REPORT
    ml_counter = 0
   DETAIL
    ml_counter = (ml_counter+ 1)
   WITH nocounter
  ;end select
  IF (ml_counter >= 1)
   SET ml_table_rowcnt = 0
   GO TO run_script
  ENDIF
 ENDIF
 IF (sbr_ccl_check(1)=0)
  GO TO exit_script
 ENDIF
 IF (sbr_rdbms_check(1)=0)
  GO TO exit_script
 ENDIF
#run_script
 IF (validate(ml_table_rows,0) != 0)
  SET ml_table_rowcnt = ml_table_rows
 ENDIF
 EXECUTE dm2_readme_spcchk_load value(ms_table_name), value(ms_operation_init), value(ml_table_rowcnt
  ),
 value(ms_column_name)
 GO TO exit_script
 SUBROUTINE sbr_add_table(ps_tbl_name,pn_tgt_ind)
   SET mr_table->l_tlst_cnt = (mr_table->l_tlst_cnt+ 1)
   SET stat = alterlist(mr_table->tlst,mr_table->l_tlst_cnt)
   SET mr_table->tlst[mr_table->l_tlst_cnt].s_table_name = cnvtupper(trim(ps_tbl_name))
   SET mr_table->tlst[mr_table->l_tlst_cnt].n_target_ind = pn_tgt_ind
   IF (pn_tgt_ind)
    SET ms_table_name = mr_table->tlst[mr_table->l_tlst_cnt].s_table_name
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_add_column(ps_column_name,pn_tgt_ind)
   SET mr_table->tlst[mr_table->l_tlst_cnt].l_clst_cnt = (mr_table->tlst[mr_table->l_tlst_cnt].
   l_clst_cnt+ 1)
   SET stat = alterlist(mr_table->tlst[mr_table->l_tlst_cnt].clst,mr_table->tlst[mr_table->l_tlst_cnt
    ].l_clst_cnt)
   SET mr_table->tlst[mr_table->l_tlst_cnt].clst[mr_table->tlst[mr_table->l_tlst_cnt].l_clst_cnt].
   s_column_name = cnvtupper(trim(ps_column_name))
   SET mr_table->tlst[mr_table->l_tlst_cnt].clst[mr_table->tlst[mr_table->l_tlst_cnt].l_clst_cnt].
   n_target_ind = pn_tgt_ind
   IF (pn_tgt_ind)
    IF (textlen(ms_column_name) > 2)
     SET ms_column_name = concat(ms_column_name,",",mr_table->tlst[mr_table->l_tlst_cnt].clst[
      mr_table->tlst[mr_table->l_tlst_cnt].l_clst_cnt].s_column_name)
    ELSE
     SET ms_column_name = mr_table->tlst[mr_table->l_tlst_cnt].clst[mr_table->tlst[mr_table->
     l_tlst_cnt].l_clst_cnt].s_column_name
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_ccl_check(pl_tlst_cnt)
  SELECT INTO "nl:"
   l.attr_name
   FROM dtableattr a,
    dtableattrl l,
    (dummyt d  WITH seq = value(mr_table->tlst[pl_tlst_cnt].l_clst_cnt))
   PLAN (a
    WHERE (a.table_name=mr_table->tlst[pl_tlst_cnt].s_table_name))
    JOIN (d)
    JOIN (l
    WHERE (l.attr_name=mr_table->tlst[pl_tlst_cnt].clst[d.seq].s_column_name)
     AND l.structtype="F"
     AND btest(l.stat,11)=0)
   HEAD REPORT
    ml_counter = 0
   DETAIL
    ml_counter = (ml_counter+ 1)
   WITH nocounter
  ;end select
  IF ((ml_counter=mr_table->tlst[pl_tlst_cnt].l_clst_cnt))
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE sbr_rdbms_check(pl_tlst_cnt)
   DECLARE mn_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    rows_val = dt.num_rows
    FROM dm2_user_tab_cols dtc,
     dm2_user_tables dt
    PLAN (dt
     WHERE (dt.table_name=mr_table->tlst[pl_tlst_cnt].s_table_name))
     JOIN (dtc
     WHERE dtc.table_name=dt.table_name
      AND expand(mn_idx,1,mr_table->tlst[pl_tlst_cnt].l_clst_cnt,dtc.column_name,mr_table->tlst[
      pl_tlst_cnt].clst[mn_idx].s_column_name))
    HEAD REPORT
     ml_counter = 0
    DETAIL
     ml_counter = (ml_counter+ 1), ml_table_rowcnt = rows_val
    WITH nocounter
   ;end select
   IF ((ml_counter=mr_table->tlst[pl_tlst_cnt].l_clst_cnt))
    IF ((mr_table->tlst[pl_tlst_cnt].n_target_ind=1))
     SET ml_table_rowcnt = (gf_fudge_factor * ml_table_rowcnt)
    ENDIF
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD mr_table
END GO
