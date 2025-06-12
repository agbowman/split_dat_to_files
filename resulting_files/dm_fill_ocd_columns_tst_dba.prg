CREATE PROGRAM dm_fill_ocd_columns_tst:dba
 INSERT  FROM dm_afd_tables
  (table_name, alpha_feature_nbr, feature_number,
  tablespace_name, pct_increase, pct_used,
  pct_free, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  schema_date, schema_instance)(SELECT
   at.table_name, at.alpha_feature_nbr, at.feature_number,
   at.tablespace_name, at.pct_increase, at.pct_used,
   at.pct_free, 0, at.updt_dt_tm,
   0, 0, 0,
   at.schema_date, at.schema_instance
   FROM dm_temp_afd_tables at
   WHERE at.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_afd_columns
  (table_name, alpha_feature_nbr, column_name,
  column_seq, data_type, data_length,
  data_precision, data_scale, nullable,
  data_default, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   ac.table_name, ac.alpha_feature_nbr, ac.column_name,
   ac.column_seq, ac.data_type, ac.data_length,
   ac.data_precision, ac.data_scale, ac.nullable,
   ac.data_default, 0, ac.updt_dt_tm,
   0, 0, 0
   FROM dm_temp_afd_columns ac
   WHERE ac.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 INSERT  FROM dm_afd_constraints
  (table_name, alpha_feature_nbr, constraint_name,
  constraint_type, parent_table_name, status_ind,
  parent_table_columns, r_constraint_name, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task, full_cons_name)(SELECT
   ac.table_name, ac.alpha_feature_nbr, ac.constraint_name,
   ac.constraint_type, ac.parent_table_name, ac.status_ind,
   ac.parent_table_columns, ac.r_constraint_name, 0,
   ac.updt_dt_tm, 0, 0,
   0, ac.constraint_name
   FROM dm_temp_afd_constraints ac
   WHERE ac.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 INSERT  FROM dm_afd_cons_columns
  (table_name, alpha_feature_nbr, constraint_name,
  column_name, position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   acc.table_name, acc.alpha_feature_nbr, acc.constraint_name,
   acc.column_name, acc.position, 0,
   acc.updt_dt_tm, 0, 0,
   0
   FROM dm_temp_afd_cons_columns acc
   WHERE acc.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_afd_indexes
  (index_name, alpha_feature_nbr, table_name,
  tablespace_name, pct_increase, pct_free,
  unique_ind, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  full_ind_name)(SELECT
   ai.index_name, ai.alpha_feature_nbr, ai.table_name,
   ai.tablespace_name, ai.pct_increase, ai.pct_free,
   ai.unique_ind, 0, ai.updt_dt_tm,
   0, 0, 0,
   ai.index_name
   FROM dm_temp_afd_indexes ai
   WHERE ai.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 INSERT  FROM dm_afd_index_columns
  (index_name, table_name, alpha_feature_nbr,
  column_name, column_position, updt_applctx,
  updt_dt_tm, updt_cnt, updt_id,
  updt_task)(SELECT
   aic.index_name, aic.table_name, aic.alpha_feature_nbr,
   aic.column_name, aic.column_position, 0,
   aic.updt_dt_tm, 0, 0,
   0
   FROM dm_temp_afd_index_columns aic
   WHERE aic.alpha_feature_nbr=afd_nbr)
  WITH nocounter
 ;end insert
 COMMIT
END GO
