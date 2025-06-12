CREATE PROGRAM dm_get_target_schema3:dba
 DECLARE ind_cnt = i4
 DECLARE dgts_perform_check = i2
 SET tgtdb->tbl_cnt = 0
 SET tcnt = 0
 SET tc_cnt = 0
 SET icnt = 0
 SET ic_cnt = 0
 SET ccnt = 0
 SET cc_cnt = 0
 SET dgts_perform_check = 0
 SET ind_cnt = 0
 FREE RECORD dgts_cb_objects
 RECORD dgts_cb_objects(
   1 obj[*]
     2 tab_name = vc
     2 obj_type = vc
     2 obj_name = vc
 )
 SELECT INTO "nl:"
  l.attr_name
  FROM dtableattr a,
   dtableattrl l
  WHERE a.table_name="DM_CB_OBJECTS"
  DETAIL
   dgts_perform_check = 1
  WITH nocounter
 ;end select
 IF (dgts_perform_check=1)
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE u.table_name="DM_CB_OBJECTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dgts_perform_check = 0
  ENDIF
 ENDIF
 IF (dgts_perform_check=1)
  SELECT INTO "nl;"
   FROM dm_cb_objects o
   WHERE o.object_type IN ("TABLE", "INDEX")
    AND o.object_status="DROP"
    AND o.active_ind=1
   ORDER BY o.object_type
   HEAD REPORT
    ind_cnt = 0
   DETAIL
    ind_cnt = (ind_cnt+ 1), stat = alterlist(dgts_cb_objects->obj,ind_cnt), dgts_cb_objects->obj[
    ind_cnt].obj_name = o.object_name
    IF (o.object_type="INDEX")
     dgts_cb_objects->obj[ind_cnt].tab_name = o.table_name
    ENDIF
    dgts_cb_objects->obj[ind_cnt].obj_type = o.object_type
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dgts_perform_check = 0
  ENDIF
 ENDIF
 SUBROUTINE dgts_check_cb_object(dgts_type,dgts_object)
   DECLARE sub_ind_cnt = i4
   DECLARE dont_build = i2
   SET sub_ind_cnt = 0
   SET dont_build = 0
   FOR (sub_ind_cnt = 1 TO size(dgts_cb_objects->obj,5))
    IF ((dgts_cb_objects->obj[sub_ind_cnt].obj_name=dgts_object))
     SET dont_build = 1
     SET sub_ind_cnt = size(dgts_cb_objects->obj,5)
    ENDIF
    IF (dont_build=0
     AND dgts_type="INDEX")
     IF ((dgts_cb_objects->obj[sub_ind_cnt].obj_name=concat(trim(substring(1,28,dgts_object)),"$C")))
      SET dont_build = 1
      SET sub_ind_cnt = size(dgts_cb_objects->obj,5)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(dont_build)
 END ;Subroutine
 IF ((fs_proc->ocd_ind=1))
  SELECT
   IF ((fs_proc->online_ind=1))
    PLAN (a1
     WHERE (a1.alpha_feature_nbr=fs_proc->ocd_number)
      AND (a1.table_name=fs_proc->online_table_name))
     JOIN (a2
     WHERE a1.table_name=a2.table_name)
     JOIN (dafe
     WHERE (dafe.environment_id=fs_proc->env[1].id)
      AND dafe.alpha_feature_nbr=a2.alpha_feature_nbr)
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ELSE
    PLAN (a1
     WHERE (a1.alpha_feature_nbr=fs_proc->ocd_number))
     JOIN (a2
     WHERE a1.table_name=a2.table_name)
     JOIN (dafe
     WHERE (dafe.environment_id=fs_proc->env[1].id)
      AND dafe.alpha_feature_nbr=a2.alpha_feature_nbr)
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ENDIF
   INTO "nl:"
   a2.table_name, a2.schema_date, sd_null_ind = nullind(a2.schema_date),
   a2.alpha_feature_nbr
   FROM dm_tables_doc dtd,
    (dummyt d2  WITH seq = 1),
    dm_afd_tables a1,
    dm_afd_tables a2,
    dm_alpha_features_env dafe
   ORDER BY a2.table_name
   HEAD a2.table_name
    dgts_skip = 0
    IF (dgts_perform_check=1)
     IF (dgts_check_cb_object("TABLE",a2.table_name)=1)
      dgts_skip = 1
     ENDIF
    ENDIF
    IF (dgts_skip=0)
     tgtdb->tbl_cnt = (tgtdb->tbl_cnt+ 1), tcnt = tgtdb->tbl_cnt, stat = alterlist(tgtdb->tbl,tcnt),
     tgtdb->tbl[tcnt].tbl_name = a2.table_name, tgtdb->tbl[tcnt].alpha_feature_nbr = fs_proc->
     ocd_number, tgtdb->tbl[tcnt].schema_date = 1
     IF (dtd.table_name=null)
      tgtdb->tbl[tcnt].reference_ind = 1
     ELSE
      tgtdb->tbl[tcnt].reference_ind = dtd.reference_ind
     ENDIF
     tgtdb->tbl[tcnt].new_ind = 0, tgtdb->tbl[tcnt].diff_ind = 0, tgtdb->tbl[tcnt].warn_ind = 0,
     tgtdb->tbl[tcnt].uptime_ind = 0, tgtdb->tbl[tcnt].downtime_ind = 0, tgtdb->tbl[tcnt].size = 0.0,
     tgtdb->tbl[tcnt].total_space = 0.0, tgtdb->tbl[tcnt].free_space = 0.0, tgtdb->tbl[tcnt].row_cnt
      = 0.0,
     tgtdb->tbl[tcnt].init_ext = 0.0, tgtdb->tbl[tcnt].next_ext = 0.0
    ENDIF
   DETAIL
    IF (dgts_skip=0)
     IF (dis_utc_ind=1)
      IF (sd_null_ind=0
       AND datetimediff(cnvtdatetimeutc(a2.schema_date),cnvtdatetimeutc(tgtdb->tbl[tcnt].schema_date)
       ) > 0)
       tgtdb->tbl[tcnt].schema_date = cnvtdatetimeutc(a2.schema_date), tgtdb->tbl[tcnt].
       alpha_feature_nbr = a2.alpha_feature_nbr, tgtdb->tbl[tcnt].tspace_name = a2.tablespace_name
      ENDIF
     ELSE
      IF (sd_null_ind=0
       AND datetimediff(cnvtdatetime(a2.schema_date),cnvtdatetime(tgtdb->tbl[tcnt].schema_date)) > 0)
       tgtdb->tbl[tcnt].schema_date = cnvtdatetime(a2.schema_date), tgtdb->tbl[tcnt].
       alpha_feature_nbr = a2.alpha_feature_nbr, tgtdb->tbl[tcnt].tspace_name = a2.tablespace_name
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
 ELSEIF ((fs_proc->inhouse_ind=1))
  SELECT
   IF (dis_utc_ind=1)
    WHERE a2.schema_date=cnvtdatetimeutc(fs_proc->schema_date)
     AND (a2.table_name=fs_proc->inhouse_table_name)
   ELSE
    WHERE a2.schema_date=cnvtdatetime(fs_proc->schema_date)
     AND (a2.table_name=fs_proc->inhouse_table_name)
   ENDIF
   INTO "nl:"
   a2.table_name
   FROM dm_adm_tables a2
   DETAIL
    tgtdb->tbl_cnt = (tgtdb->tbl_cnt+ 1), tcnt = tgtdb->tbl_cnt, stat = alterlist(tgtdb->tbl,tcnt),
    tgtdb->tbl[tcnt].tbl_name = a2.table_name, tgtdb->tbl[tcnt].tspace_name = a2.tablespace_name,
    tgtdb->tbl[tcnt].reference_ind = 1,
    tgtdb->tbl[tcnt].new_ind = 0, tgtdb->tbl[tcnt].diff_ind = 0, tgtdb->tbl[tcnt].warn_ind = 0,
    tgtdb->tbl[tcnt].uptime_ind = 0, tgtdb->tbl[tcnt].downtime_ind = 0, tgtdb->tbl[tcnt].size = 0.0,
    tgtdb->tbl[tcnt].total_space = 0.0, tgtdb->tbl[tcnt].free_space = 0.0, tgtdb->tbl[tcnt].row_cnt
     = 0.0,
    tgtdb->tbl[tcnt].init_ext = 0.0, tgtdb->tbl[tcnt].next_ext = 0.0
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF ((fs_proc->online_ind=1)
    AND dis_utc_ind=1)
    PLAN (a2
     WHERE a2.schema_date=cnvtdatetimeutc(fs_proc->schema_date)
      AND (a2.table_name=fs_proc->online_table_name))
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ELSEIF ((fs_proc->online_ind=1)
    AND dis_utc_ind=0)
    PLAN (a2
     WHERE a2.schema_date=cnvtdatetime(fs_proc->schema_date)
      AND (a2.table_name=fs_proc->online_table_name))
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ELSEIF (dis_utc_ind=0)
    PLAN (a2
     WHERE a2.schema_date=cnvtdatetime(fs_proc->schema_date))
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ELSE
    PLAN (a2
     WHERE a2.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
     JOIN (d2)
     JOIN (dtd
     WHERE a2.table_name=dtd.table_name)
   ENDIF
   INTO "nl:"
   a2.table_name
   FROM dm_tables_doc dtd,
    (dummyt d2  WITH seq = 1),
    dm_tables a2
   ORDER BY a2.table_name
   DETAIL
    dgts_skip = 0
    IF (dgts_perform_check=1)
     IF (dgts_check_cb_object("TABLE",a2.table_name)=1)
      dgts_skip = 1
     ENDIF
    ENDIF
    IF (dgts_skip=0)
     tgtdb->tbl_cnt = (tgtdb->tbl_cnt+ 1), tcnt = tgtdb->tbl_cnt, stat = alterlist(tgtdb->tbl,tcnt),
     tgtdb->tbl[tcnt].tbl_name = a2.table_name, tgtdb->tbl[tcnt].tspace_name = a2.tablespace_name
     IF (dtd.table_name=null)
      tgtdb->tbl[tcnt].reference_ind = 1
     ELSE
      tgtdb->tbl[tcnt].reference_ind = dtd.reference_ind
     ENDIF
     tgtdb->tbl[tcnt].new_ind = 0, tgtdb->tbl[tcnt].diff_ind = 0, tgtdb->tbl[tcnt].warn_ind = 0,
     tgtdb->tbl[tcnt].uptime_ind = 0, tgtdb->tbl[tcnt].downtime_ind = 0, tgtdb->tbl[tcnt].size = 0.0,
     tgtdb->tbl[tcnt].total_space = 0.0, tgtdb->tbl[tcnt].free_space = 0.0, tgtdb->tbl[tcnt].row_cnt
      = 0.0,
     tgtdb->tbl[tcnt].init_ext = 0.0, tgtdb->tbl[tcnt].next_ext = 0.0
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
 ENDIF
 SELECT
  IF ((fs_proc->ocd_ind=1))
   FROM dm_afd_columns c,
    (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
     AND (c.alpha_feature_nbr=tgtdb->tbl[d.seq].alpha_feature_nbr))
  ELSEIF ((fs_proc->inhouse_ind=1)
   AND dis_utc_ind=1)
   FROM dm_adm_columns c,
    (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
     AND c.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
  ELSEIF ((fs_proc->inhouse_ind=1)
   AND dis_utc_ind=0)
   FROM dm_adm_columns c,
    (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
     AND c.schema_date=cnvtdatetime(fs_proc->schema_date))
  ELSEIF (dis_utc_ind=0)
   FROM dm_columns c,
    (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
     AND c.schema_date=cnvtdatetime(fs_proc->schema_date))
  ELSE
   FROM dm_columns c,
    (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
     AND c.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
  ENDIF
  INTO "nl:"
  d.seq
  ORDER BY c.table_name, c.column_seq
  HEAD c.table_name
   tgtdb->tbl[d.seq].tbl_col_cnt = 0, tgtdb->tbl[d.seq].ind_cnt = 0, tgtdb->tbl[d.seq].cons_cnt = 0
  DETAIL
   tgtdb->tbl[d.seq].tbl_col_cnt = (tgtdb->tbl[d.seq].tbl_col_cnt+ 1), tc_cnt = tgtdb->tbl[d.seq].
   tbl_col_cnt, stat = alterlist(tgtdb->tbl[d.seq].tbl_col,tc_cnt),
   tgtdb->tbl[d.seq].tbl_col[tc_cnt].col_name = c.column_name, tgtdb->tbl[d.seq].tbl_col[tc_cnt].
   data_type = c.data_type, tgtdb->tbl[d.seq].tbl_col[tc_cnt].data_length = c.data_length,
   tgtdb->tbl[d.seq].tbl_col[tc_cnt].data_default = c.data_default, tgtdb->tbl[d.seq].tbl_col[tc_cnt]
   .nullable = c.nullable, tgtdb->tbl[d.seq].tbl_col[tc_cnt].col_seq = c.column_seq,
   tgtdb->tbl[d.seq].tbl_col[tc_cnt].new_ind = 0, tgtdb->tbl[d.seq].tbl_col[tc_cnt].diff_dtype_ind =
   0, tgtdb->tbl[d.seq].tbl_col[tc_cnt].diff_dlength_ind = 0,
   tgtdb->tbl[d.seq].tbl_col[tc_cnt].diff_nullable_ind = 0, tgtdb->tbl[d.seq].tbl_col[tc_cnt].
   diff_default_ind = 0, tgtdb->tbl[d.seq].tbl_col[tc_cnt].null_to_notnull_ind = 0,
   tgtdb->tbl[d.seq].tbl_col[tc_cnt].downtime_ind = 0
  WITH nocounter
 ;end select
 IF ((tgtdb->tbl_cnt > 0))
  SELECT
   IF ((fs_proc->ocd_ind=1))
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_afd_indexes a,
     dm_afd_index_columns c
    PLAN (d)
     JOIN (a
     WHERE (a.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND (a.alpha_feature_nbr=tgtdb->tbl[d.seq].alpha_feature_nbr))
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.alpha_feature_nbr=a.alpha_feature_nbr
      AND c.index_name=a.index_name)
   ELSEIF ((fs_proc->inhouse_ind=1)
    AND dis_utc_ind=1)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_adm_indexes a,
     dm_adm_index_columns c
    PLAN (d)
     JOIN (a
     WHERE (a.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND a.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=a.schema_date
      AND c.index_name=a.index_name)
   ELSEIF ((fs_proc->inhouse_ind=1)
    AND dis_utc_ind=0)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_adm_indexes a,
     dm_adm_index_columns c
    PLAN (d)
     JOIN (a
     WHERE (a.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND a.schema_date=cnvtdatetime(fs_proc->schema_date))
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=a.schema_date
      AND c.index_name=a.index_name)
   ELSEIF (dis_utc_ind=0)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_indexes a,
     dm_index_columns c
    PLAN (d)
     JOIN (a
     WHERE (a.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND a.schema_date=cnvtdatetime(fs_proc->schema_date))
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=a.schema_date
      AND c.index_name=a.index_name)
   ELSE
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_indexes a,
     dm_index_columns c
    PLAN (d)
     JOIN (a
     WHERE (a.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND a.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=a.schema_date
      AND c.index_name=a.index_name)
   ENDIF
   INTO "nl:"
   d.seq
   ORDER BY c.table_name, c.index_name, c.column_position
   HEAD c.index_name
    dgts_skip = 0
    IF (dgts_perform_check=1)
     IF (dgts_check_cb_object("INDEX",c.index_name)=1)
      dgts_skip = 1
     ENDIF
    ENDIF
    IF (dgts_skip=0)
     tgtdb->tbl[d.seq].ind_cnt = (tgtdb->tbl[d.seq].ind_cnt+ 1), icnt = tgtdb->tbl[d.seq].ind_cnt,
     stat = alterlist(tgtdb->tbl[d.seq].ind,icnt),
     tgtdb->tbl[d.seq].ind[icnt].ind_name = a.index_name, tgtdb->tbl[d.seq].ind[icnt].tspace_name = a
     .tablespace_name, tgtdb->tbl[d.seq].ind[icnt].unique_ind = a.unique_ind,
     tgtdb->tbl[d.seq].ind[icnt].new_ind = 0, tgtdb->tbl[d.seq].ind[icnt].diff_name_ind = 0, tgtdb->
     tbl[d.seq].ind[icnt].diff_unique_ind = 0,
     tgtdb->tbl[d.seq].ind[icnt].diff_col_ind = 0, tgtdb->tbl[d.seq].ind[icnt].diff_cons_ind = 0,
     tgtdb->tbl[d.seq].ind[icnt].build_ind = 0,
     tgtdb->tbl[d.seq].ind[icnt].downtime_ind = 0, tgtdb->tbl[d.seq].ind[icnt].init_ext = 0.0, tgtdb
     ->tbl[d.seq].ind[icnt].next_ext = 0.0,
     tgtdb->tbl[d.seq].ind[icnt].size = 0.0, tgtdb->tbl[d.seq].ind[icnt].ind_col_cnt = 0
    ENDIF
   DETAIL
    IF (dgts_skip=0)
     tgtdb->tbl[d.seq].ind[icnt].ind_col_cnt = (tgtdb->tbl[d.seq].ind[icnt].ind_col_cnt+ 1), ic_cnt
      = tgtdb->tbl[d.seq].ind[icnt].ind_col_cnt, stat = alterlist(tgtdb->tbl[d.seq].ind[icnt].ind_col,
      ic_cnt),
     tgtdb->tbl[d.seq].ind[icnt].ind_col[ic_cnt].col_name = c.column_name, tgtdb->tbl[d.seq].ind[icnt
     ].ind_col[ic_cnt].col_position = c.column_position
    ENDIF
   WITH nocounter
  ;end select
  SELECT
   IF (fs_proc->ocd_ind)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_afd_constraints c,
     dm_afd_cons_columns cc
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND (c.alpha_feature_nbr=tgtdb->tbl[d.seq].alpha_feature_nbr))
     JOIN (cc
     WHERE cc.table_name=c.table_name
      AND cc.constraint_name=c.constraint_name
      AND cc.alpha_feature_nbr=c.alpha_feature_nbr)
   ELSEIF ((fs_proc->inhouse_ind=1)
    AND dis_utc_ind=1)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_adm_constraints c,
     dm_adm_cons_columns cc
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
     JOIN (cc
     WHERE cc.table_name=c.table_name
      AND cc.constraint_name=c.constraint_name
      AND cc.schema_date=c.schema_date)
   ELSEIF ((fs_proc->inhouse_ind=1)
    AND dis_utc_ind=0)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_adm_constraints c,
     dm_adm_cons_columns cc
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=cnvtdatetime(fs_proc->schema_date))
     JOIN (cc
     WHERE cc.table_name=c.table_name
      AND cc.constraint_name=c.constraint_name
      AND cc.schema_date=c.schema_date)
   ELSEIF (dis_utc_ind=0)
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_constraints c,
     dm_cons_columns cc
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=cnvtdatetime(fs_proc->schema_date))
     JOIN (cc
     WHERE cc.table_name=c.table_name
      AND cc.constraint_name=c.constraint_name
      AND cc.schema_date=c.schema_date)
   ELSE
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     dm_constraints c,
     dm_cons_columns cc
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=tgtdb->tbl[d.seq].tbl_name)
      AND c.schema_date=cnvtdatetimeutc(fs_proc->schema_date))
     JOIN (cc
     WHERE cc.table_name=c.table_name
      AND cc.constraint_name=c.constraint_name
      AND cc.schema_date=c.schema_date)
   ENDIF
   INTO "nl:"
   d.seq
   ORDER BY cc.table_name, cc.constraint_name, cc.position
   HEAD cc.constraint_name
    tgtdb->tbl[d.seq].cons_cnt = (tgtdb->tbl[d.seq].cons_cnt+ 1), ccnt = tgtdb->tbl[d.seq].cons_cnt,
    stat = alterlist(tgtdb->tbl[d.seq].cons,ccnt),
    tgtdb->tbl[d.seq].cons[ccnt].cons_name = c.constraint_name, tgtdb->tbl[d.seq].cons[ccnt].
    cons_type = c.constraint_type
    IF (c.constraint_type="R")
     tgtdb->tbl[d.seq].cons[ccnt].status_ind = 0
    ELSE
     tgtdb->tbl[d.seq].cons[ccnt].status_ind = c.status_ind
    ENDIF
    tgtdb->tbl[d.seq].cons[ccnt].r_constraint_name = c.r_constraint_name, tgtdb->tbl[d.seq].cons[ccnt
    ].parent_table = c.parent_table_name, tgtdb->tbl[d.seq].cons[ccnt].parent_table_columns = c
    .parent_table_columns,
    tgtdb->tbl[d.seq].cons[ccnt].new_ind = 0, tgtdb->tbl[d.seq].cons[ccnt].diff_name_ind = 0, tgtdb->
    tbl[d.seq].cons[ccnt].diff_col_ind = 0,
    tgtdb->tbl[d.seq].cons[ccnt].diff_status_ind = 0, tgtdb->tbl[d.seq].cons[ccnt].diff_parent_ind =
    0, tgtdb->tbl[d.seq].cons[ccnt].diff_ind_ind = 0,
    tgtdb->tbl[d.seq].cons[ccnt].build_ind = 0, tgtdb->tbl[d.seq].cons[ccnt].downtime_ind = 0, tgtdb
    ->tbl[d.seq].cons[ccnt].fk_cnt = 0,
    stat = alterlist(tgtdb->tbl[d.seq].cons[ccnt].fk,0), tgtdb->tbl[d.seq].cons[ccnt].cons_col_cnt =
    0
   DETAIL
    tgtdb->tbl[d.seq].cons[ccnt].cons_col_cnt = (tgtdb->tbl[d.seq].cons[ccnt].cons_col_cnt+ 1),
    cc_cnt = tgtdb->tbl[d.seq].cons[ccnt].cons_col_cnt, stat = alterlist(tgtdb->tbl[d.seq].cons[ccnt]
     .cons_col,cc_cnt),
    tgtdb->tbl[d.seq].cons[ccnt].cons_col[cc_cnt].col_name = cc.column_name, tgtdb->tbl[d.seq].cons[
    ccnt].cons_col[cc_cnt].col_position = cc.position
   WITH nocounter
  ;end select
  EXECUTE dm_get_target_tspace
  IF ((fs_proc->online_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
    PLAN (d)
    DETAIL
     tgtdb->tbl[d.seq].tbl_name = build(substring(1,28,tgtdb->tbl[d.seq].tbl_name),"$C")
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
