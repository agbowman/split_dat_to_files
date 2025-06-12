CREATE PROGRAM dm_fill_temp_ocd_columns_tst:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SET cdate = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3),2)
 SET cdate = cnvtdatetime(format(cdate,"dd-mmm-yyyy hh:mm;;d"))
 IF ((tab_list->count > 0))
  SET cnt = 0
  FOR (cnt = 1 TO tab_list->count)
    FREE SET r1
    RECORD r1(
      1 feature_date = dq8
      1 ocd_date = dq8
    )
    SET r1->feature_date = 0
    SET r1->ocd_date = 0
    SELECT INTO "nl:"
     dcf.schema_dt_tm
     FROM dm_feature_tables_env dcf
     WHERE (dcf.table_name=tab_list->qual[cnt].table_name)
      AND dcf.feature_number=fnumber
     DETAIL
      IF ((dcf.schema_dt_tm > r1->feature_date))
       r1->feature_date = dcf.schema_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     dcf.schema_date
     FROM dm_project_status_env dcf
     WHERE (dcf.proj_name=tab_list->qual[cnt].table_name)
      AND dcf.feature=fnumber
     DETAIL
      IF ((dcf.schema_date > r1->feature_date))
       r1->feature_date = dcf.schema_date
      ENDIF
     WITH nocounter
    ;end select
    SET old_number = tab_list->qual[cnt].old_ocd_number
    IF (old_number=0)
     SET ocd_flag = 0
    ELSE
     SET ocd_flag = 1
    ENDIF
    CALL echo(build("OCD Flag is:",ocd_flag))
    IF ((current_ocd->schema_date_usage=1))
     INSERT  FROM dm_temp_afd_tables
      (table_name, alpha_feature_nbr, feature_number,
      tablespace_name, pct_increase, pct_used,
      pct_free, updt_applctx, updt_dt_tm,
      updt_cnt, updt_id, updt_task,
      schema_date, schema_instance)(SELECT
       at.table_name, afd_nbr, fnumber,
       at.tablespace_name, at.pct_increase, at.pct_used,
       at.pct_free, 0, cnvtdatetime(cdate),
       0, 0, 0,
       cnvtdatetime(r1->feature_date), at.schema_instance
       FROM dm_adm_tables at
       WHERE at.table_name=trim(tab_list->qual[cnt].table_name)
        AND at.schema_date=cnvtdatetime(r1->feature_date))
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM dm_temp_afd_tables
      (table_name, alpha_feature_nbr, feature_number,
      tablespace_name, pct_increase, pct_used,
      pct_free, updt_applctx, updt_dt_tm,
      updt_cnt, updt_id, updt_task,
      schema_date, schema_instance)(SELECT
       at.table_name, afd_nbr, fnumber,
       at.tablespace_name, at.pct_increase, at.pct_used,
       at.pct_free, 0, cnvtdatetime(cdate),
       0, 0, 0,
       cnvtdatetime(sch_date), at.schema_instance
       FROM dm_adm_tables at
       WHERE at.table_name=trim(tab_list->qual[cnt].table_name)
        AND at.schema_date=cnvtdatetime(r1->feature_date))
      WITH nocounter
     ;end insert
    ENDIF
    COMMIT
    FOR (a = 1 TO tab_list->qual[cnt].col_knt)
      IF ((request->feature[i].qual[cnt].column[a].feature_ind=1))
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
         FROM dm_adm_columns ac
         WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
          AND ac.schema_date=cnvtdatetime(r1->feature_date)
          AND (ac.column_name=request->feature[i].qual[cnt].column[a].column_name))
        WITH nocounter
       ;end insert
      ELSE
       IF (ocd_flag=1)
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
          FROM dm_afd_columns ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.alpha_feature_nbr=old_number
           AND (ac.column_name=request->feature[i].qual[cnt].column[a].column_name))
         WITH nocounter
        ;end insert
       ELSE
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
          FROM dm_columns ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.schema_date=cnvtdatetime(rev_date)
           AND (ac.column_name=request->feature[i].qual[cnt].column[a].column_name))
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
    ENDFOR
    COMMIT
    FOR (a = 1 TO tab_list->qual[cnt].cons_knt)
      IF ((request->feature[i].qual[cnt].constraint[a].feature_ind=1))
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
         FROM dm_adm_constraints ac
         WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
          AND ac.constraint_type="R"
          AND ac.schema_date=cnvtdatetime(r1->feature_date)
          AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
         FROM dm_adm_constraints ac
         WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
          AND ac.constraint_type IN ("P", "U")
          AND ac.schema_date=cnvtdatetime(r1->feature_date)
          AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
          dm_adm_constraints ac
         WHERE acc.table_name=trim(tab_list->qual[cnt].table_name)
          AND acc.schema_date=cnvtdatetime(r1->feature_date)
          AND ac.table_name=acc.table_name
          AND ac.schema_date=acc.schema_date
          AND ac.constraint_name=acc.constraint_name
          AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
        WITH nocounter
       ;end insert
       COMMIT
      ELSE
       IF (ocd_flag=1)
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
          FROM dm_afd_constraints ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.alpha_feature_nbr=old_number
           AND ac.constraint_type="R"
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
          FROM dm_afd_constraints ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.alpha_feature_nbr=old_number
           AND ac.constraint_type IN ("P", "U")
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
           dm_afd_constraints ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.alpha_feature_nbr=old_number
           AND ac.table_name=acc.table_name
           AND ac.alpha_feature_nbr=acc.alpha_feature_nbr
           AND ac.constraint_name=acc.constraint_name
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
         WITH nocounter
        ;end insert
       ELSE
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
          FROM dm_constraints ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.constraint_type="R"
           AND ac.schema_date=cnvtdatetime(rev_date)
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
          FROM dm_constraints ac
          WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
           AND ac.constraint_type IN ("P", "U")
           AND ac.schema_date=cnvtdatetime(rev_date)
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
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
           dm_constraints ac
          WHERE acc.table_name=trim(tab_list->qual[cnt].table_name)
           AND acc.schema_date=cnvtdatetime(rev_date)
           AND ac.table_name=acc.table_name
           AND ac.schema_date=acc.schema_date
           AND ac.constraint_name=acc.constraint_name
           AND (ac.constraint_name=request->feature[i].qual[cnt].constraint[a].constraint_name))
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
    ENDFOR
    FOR (a = 1 TO tab_list->qual[cnt].index_knt)
      IF ((request->feature[i].qual[cnt].index[a].feature_ind=1))
       INSERT  FROM dm_temp_afd_indexes
        (index_name, alpha_feature_nbr, table_name,
        tablespace_name, pct_increase, pct_free,
        unique_ind, updt_applctx, updt_dt_tm,
        updt_cnt, updt_id, updt_task)(SELECT
         ai.index_name, afd_nbr, ai.table_name,
         ai.tablespace_name, ai.pct_increase, ai.pct_free,
         ai.unique_ind, 0, cnvtdatetime(cdate),
         0, 0, 0
         FROM dm_adm_indexes ai
         WHERE ai.table_name=trim(tab_list->qual[cnt].table_name)
          AND ai.schema_date=cnvtdatetime(r1->feature_date)
          AND (ai.index_name=request->feature[i].qual[cnt].index[a].index_name))
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
         FROM dm_adm_index_columns aic
         WHERE aic.table_name=trim(tab_list->qual[cnt].table_name)
          AND aic.schema_date=cnvtdatetime(r1->feature_date)
          AND (aic.index_name=request->feature[i].qual[cnt].index[a].index_name))
        WITH nocounter
       ;end insert
      ELSE
       IF (ocd_flag=1)
        INSERT  FROM dm_temp_afd_indexes
         (index_name, alpha_feature_nbr, table_name,
         tablespace_name, pct_increase, pct_free,
         unique_ind, updt_applctx, updt_dt_tm,
         updt_cnt, updt_id, updt_task)(SELECT DISTINCT
          ai.index_name, afd_nbr, ai.table_name,
          ai.tablespace_name, ai.pct_increase, ai.pct_free,
          ai.unique_ind, 0, cnvtdatetime(cdate),
          0, 0, 0
          FROM dm_afd_indexes ai
          WHERE ai.table_name=trim(tab_list->qual[cnt].table_name)
           AND ai.alpha_feature_nbr=old_number
           AND (ai.index_name=request->feature[i].qual[cnt].index[a].index_name))
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
          FROM dm_afd_index_columns aic
          WHERE aic.table_name=trim(tab_list->qual[cnt].table_name)
           AND aic.alpha_feature_nbr=old_number
           AND (aic.index_name=request->feature[i].qual[cnt].index[a].index_name))
         WITH nocounter
        ;end insert
       ELSE
        INSERT  FROM dm_temp_afd_indexes
         (index_name, alpha_feature_nbr, table_name,
         tablespace_name, pct_increase, pct_free,
         unique_ind, updt_applctx, updt_dt_tm,
         updt_cnt, updt_id, updt_task)(SELECT
          ai.index_name, afd_nbr, ai.table_name,
          ai.tablespace_name, ai.pct_increase, ai.pct_free,
          ai.unique_ind, 0, cnvtdatetime(cdate),
          0, 0, 0
          FROM dm_indexes ai
          WHERE ai.table_name=trim(tab_list->qual[cnt].table_name)
           AND ai.schema_date=cnvtdatetime(rev_date)
           AND (ai.index_name=request->feature[i].qual[cnt].index[a].index_name))
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
          FROM dm_index_columns aic
          WHERE aic.table_name=trim(tab_list->qual[cnt].table_name)
           AND aic.schema_date=cnvtdatetime(rev_date)
           AND (aic.index_name=request->feature[i].qual[cnt].index[a].index_name))
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
    ENDFOR
    COMMIT
  ENDFOR
 ENDIF
END GO
