CREATE PROGRAM dm_ocd_fill_test:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SET cdate = cnvtdatetime(curdate,curtime3)
 SET cdate = cnvtdatetime(format(cdate,"dd-mmm-yyyy hh:mm;;d"))
 FREE SET r1
 RECORD r1(
   1 qual[*]
     2 feature_date = dq8
     2 ocd_date = dq8
     2 old_number = i4
     2 ocd_flag = i2
   1 count = i4
 )
 SET r1->count = 0
 SET stat = alterlist(r1->qual,10)
 SELECT INTO "nl:"
  dcf.schema_dt_tm
  FROM dm_feature_tables_env dcf,
   (dummyt d  WITH seq = value(tab_list->count))
  PLAN (d)
   JOIN (dcf
   WHERE (dcf.table_name=tab_list->qual[d.seq].table_name)
    AND dcf.feature_number=fnumber)
  HEAD d.seq
   stat = alterlist(r1->qual,d.seq), r1->qual[d.seq].feature_date = 0, r1->qual[d.seq].old_number =
   tab_list->qual[d.seq].old_ocd_number
   IF ((r1->qual[d.seq].old_number=0))
    r1->qual[d.seq].ocd_flag = 0
   ELSE
    r1->qual[d.seq].ocd_flag = 1
   ENDIF
  DETAIL
   IF ((dcf.schema_dt_tm > r1->qual[d.seq].feature_date))
    r1->qual[d.seq].feature_date = dcf.schema_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 INSERT  FROM dm_temp_afd_tables
  (table_name, alpha_feature_nbr, feature_number,
  tablespace_name, pct_increase, pct_used,
  pct_free, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  schema_date)(SELECT
   at.table_name, afd_nbr, fnumber,
   at.tablespace_name, at.pct_increase, at.pct_used,
   at.pct_free, 0, cnvtdatetime(cdate),
   0, 0, 0,
   cnvtdatetime(sch_date)
   FROM dm_adm_tables at,
    (dummyt d  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (at
    WHERE at.table_name=trim(tab_list->qual[d.seq].table_name)
     AND at.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date))
    )
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_temp_afd_columns
  (table_name, alpha_feature_nbr, column_name,
  column_seq, data_type, data_length,
  data_precision, data_scale, nullable,
  data_default, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   ac.table_name, afd_nbr, ac.column_name,
   ac.column_seq, ac.data_type, ac.data_length,
   ac.data_precision, ac.data_scale, ac.nullable,
   ac.data_default, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_adm_columns ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date)
     AND (ac.column_name=request->feature[i].qual[d.seq].column[d1.seq].column_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_columns
  (table_name, alpha_feature_nbr, column_name,
  column_seq, data_type, data_length,
  data_precision, data_scale, nullable,
  data_default, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT DISTINCT
   ac.table_name, afd_nbr, ac.column_name,
   ac.column_seq, ac.data_type, ac.data_length,
   ac.data_precision, ac.data_scale, ac.nullable,
   ac.data_default, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_afd_columns ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND (ac.alpha_feature_nbr=r1->qual[d.seq].old_number)
     AND (ac.column_name=request->feature[i].qual[d.seq].column[d1.seq].column_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_columns
  (table_name, alpha_feature_nbr, column_name,
  column_seq, data_type, data_length,
  data_precision, data_scale, nullable,
  data_default, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   ac.table_name, afd_nbr, ac.column_name,
   ac.column_seq, ac.data_type, ac.data_length,
   ac.data_precision, ac.data_scale, ac.nullable,
   ac.data_default, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_columns ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.schema_date=cnvtdatetime(rev_date)
     AND (ac.column_name=request->feature[i].qual[d.seq].column[d1.seq].column_name))
    )
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 0,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_adm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.constraint_type="R"
     AND ac.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date)
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 1,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_adm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.constraint_type IN ("P", "U")
     AND ac.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date)
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_cons_columns
  (table_name, alpha_feature_nbr, constraint_name,
  column_name, position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   acc.table_name, afd_nbr, acc.constraint_name,
   acc.column_name, acc.position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_adm_cons_columns acc,
    dm_adm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=1))
    JOIN (acc
    WHERE acc.table_name=trim(tab_list->qual[d.seq].table_name)
     AND acc.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date))
    JOIN (ac
    WHERE ac.table_name=acc.table_name
     AND ac.schema_date=acc.schema_date
     AND ac.constraint_name=acc.constraint_name
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT DISTINCT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 0,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_afd_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.alpha_feature_nbr=old_number
     AND ac.constraint_type="R"
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT DISTINCT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 1,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_afd_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND (ac.alpha_feature_nbr=r1->qual[d.seq].old_number)
     AND ac.constraint_type IN ("P", "U")
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_cons_columns
  (table_name, alpha_feature_nbr, constraint_name,
  column_name, position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT DISTINCT
   acc.table_name, afd_nbr, acc.constraint_name,
   acc.column_name, acc.position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_afd_cons_columns acc,
    dm_afd_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND (ac.alpha_feature_nbr=r1->qual[d.seq].old_number)
     AND ac.table_name=acc.table_name
     AND ac.alpha_feature_nbr=acc.alpha_feature_nbr
     AND ac.constraint_name=acc.constraint_name
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 0,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ac.constraint_type="R"
     AND ac.schema_date=cnvtdatetime(rev_date)
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   ac.table_name, afd_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, 1,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ac
    WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
     AND ac.constraint_type IN ("P", "U")
     AND ac.schema_date=cnvtdatetime(rev_date)
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_cons_columns
  (table_name, alpha_feature_nbr, constraint_name,
  column_name, position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   acc.table_name, afd_nbr, acc.constraint_name,
   acc.column_name, acc.position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_cons_columns acc,
    dm_constraints ac,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].col_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].column[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ac
    WHERE acc.table_name=trim(tab_list->qual[d.seq].table_name)
     AND acc.schema_date=cnvtdatetime(rev_date)
     AND ac.table_name=acc.table_name
     AND ac.schema_date=acc.schema_date
     AND ac.constraint_name=acc.constraint_name
     AND (ac.constraint_name=request->feature[i].qual[d.seq].constraint[d1.seq].constraint_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_indexes
  (index_name, alpha_feature_nbr, table_name,
  tablespace_name, pct_increase, pct_free,
  unique_ind, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   ai.index_name, afd_nbr, ai.table_name,
   ai.tablespace_name, ai.pct_increase, ai.pct_free,
   ai.unique_ind, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_adm_indexes ai,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=1))
    JOIN (ai
    WHERE ai.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ai.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date)
     AND (ai.index_name=request->feature[i].qual[d.seq].index[d1.seq].index_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_index_columns
  (index_name, table_name, alpha_feature_nbr,
  column_name, column_position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   aic.index_name, aic.table_name, afd_nbr,
   aic.column_name, aic.column_position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_adm_index_columns aic,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=1))
    JOIN (ai
    WHERE aic.table_name=trim(tab_list->qual[d.seq].table_name)
     AND aic.schema_date=cnvtdatetime(r1->qual[d.seq].feature_date)
     AND (aic.index_name=request->feature[i].qual[d.seq].index[d1.seq].index_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_indexes
  (index_name, alpha_feature_nbr, table_name,
  tablespace_name, pct_increase, pct_free,
  unique_ind, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT DISTINCT
   ai.index_name, afd_nbr, ai.table_name,
   ai.tablespace_name, ai.pct_increase, ai.pct_free,
   ai.unique_ind, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_afd_indexes ai,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ai
    WHERE ai.table_name=trim(tab_list->qual[d.seq].table_name)
     AND (ai.alpha_feature_nbr=r1->qual[d.seq].old_number)
     AND (ai.index_name=request->feature[i].qual[d.seq].index[d2.seq].index_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_index_columns
  (index_name, table_name, alpha_feature_nbr,
  column_name, column_position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT DISTINCT
   aic.index_name, aic.table_name, afd_nbr,
   aic.column_name, aic.column_position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_afd_index_columns aic,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=1))
    JOIN (ai
    WHERE aic.table_name=trim(tab_list->qual[d.seq].table_name)
     AND (aic.alpha_feature_nbr=r1->qual[d.seq].old_number)
     AND (aic.index_name=request->feature[i].qual[d.seq].index[d1.seq].index_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_indexes
  (index_name, alpha_feature_nbr, table_name,
  tablespace_name, pct_increase, pct_free,
  unique_ind, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   ai.index_name, afd_nbr, ai.table_name,
   ai.tablespace_name, ai.pct_increase, ai.pct_free,
   ai.unique_ind, 0, cnvtdatetime(cdate),
   0, 0, 0
   FROM dm_indexes ai,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ai
    WHERE ai.table_name=trim(tab_list->qual[d.seq].table_name)
     AND ai.schema_date=cnvtdatetime(rev_date)
     AND (ai.index_name=request->feature[i].qual[d.seq].index[d1.seq].index_name))
    )
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_afd_index_columns
  (index_name, table_name, alpha_feature_nbr,
  column_name, column_position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   aic.index_name, aic.table_name, afd_nbr,
   aic.column_name, aic.column_position, 0,
   cnvtdatetime(cdate), 0, 0,
   0
   FROM dm_index_columns aic,
    (dummyt d  WITH seq = value(tab_list->count)),
    (dummyt d1  WITH seq = value(tab_list->qual[d.seq].index_knt)),
    (dummyt d2  WITH seq = value(tab_list->count))
   PLAN (d)
    JOIN (d1
    WHERE (request->feature[i].qual[d.seq].index[d1.seq].feature_ind=0))
    JOIN (d2
    WHERE (r1->qual[d2.seq].ocd_flag=0))
    JOIN (ai
    WHERE aic.table_name=trim(tab_list->qual[d.seq].table_name)
     AND aic.schema_date=cnvtdatetime(rev_date)
     AND (aic.index_name=request->feature[i].qual[d.seq].index[d1.seq].index_name))
    )
  WITH nocounter
 ;end insert
 COMMIT
END GO
