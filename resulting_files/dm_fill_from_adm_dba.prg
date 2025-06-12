CREATE PROGRAM dm_fill_from_adm:dba
 SET dm_schema_date = cnvtdatetime( $1)
 CALL echo("Deleting Schema Date. ")
 DELETE  FROM dm_index_columns a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_columns a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_indexes a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_tables a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_cons_columns a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_constraints a
  WHERE a.schema_date=cnvtdatetime( $1)
  WITH nocounter
 ;end delete
 COMMIT
 FREE SET list
 RECORD list(
   1 tbl[*]
     2 table_name = vc
     2 schema_date = dq8
 )
 SET table_cnt = 0
 SELECT DISTINCT INTO "nl:"
  a.table_name, a.schema_dt_tm
  FROM dm_features b,
   dm_feature_tables_env a
  PLAN (a)
   JOIN (b
   WHERE b.feature_number=a.feature_number
    AND (((b.feature_status= $2)) OR ((b.feature_status= $3))) )
  ORDER BY a.table_name, a.schema_dt_tm DESC
  HEAD a.table_name
   x = 0, table_cnt = (table_cnt+ 1)
   IF (mod(table_cnt,10)=1)
    stat = alterlist(list->tbl,(table_cnt+ 9))
   ENDIF
   list->tbl[table_cnt].table_name = a.table_name, list->tbl[table_cnt].schema_date = a.schema_dt_tm
  WITH nocounter, noforms
 ;end select
 FOR (x = 1 TO table_cnt)
   INSERT  FROM dm_tables
    (table_name, schema_date, tablespace_name,
    pct_increase, pct_used, pct_free,
    updt_applctx, updt_dt_tm, updt_cnt,
    updt_id, updt_task)(SELECT
     at.table_name, cnvtdatetime( $1), at.tablespace_name,
     at.pct_increase, at.pct_used, at.pct_free,
     0, cnvtdatetime(curdate,curtime3), 0,
     0, 0
     FROM dm_adm_tables at
     WHERE at.table_name=trim(list->tbl[x].table_name)
      AND at.schema_date=cnvtdatetime(list->tbl[x].schema_date))
   ;end insert
   COMMIT
   FREE SET data_def
   RECORD data_def(
     1 qual[*]
       2 col_name = vc
     1 ncnt = i2
   )
   SET data_def->ncnt = 0
   SET stat = alterlist(data_def->qual,10)
   SELECT INTO "nl:"
    c.column_name, c.data_default
    FROM dm_adm_columns c
    WHERE c.table_name=trim(list->tbl[x].table_name)
     AND c.schema_date=cnvtdatetime(list->tbl[x].schema_date)
    DETAIL
     IF (trim(c.data_default)="NULL")
      data_def->ncnt = (data_def->ncnt+ 1), stat = alterlist(data_def->qual,data_def->ncnt), data_def
      ->qual[data_def->ncnt].col_name = c.column_name
     ENDIF
    WITH nocounter
   ;end select
   SET z = 0
   FOR (z = 1 TO data_def->ncnt)
    UPDATE  FROM dm_adm_columns c
     SET c.data_default = null
     WHERE c.table_name=trim(list->tbl[x].table_name)
      AND c.schema_date=cnvtdatetime(list->tbl[x].schema_date)
      AND (c.column_name=data_def->qual[z].col_name)
    ;end update
    COMMIT
   ENDFOR
   INSERT  FROM dm_columns
    (table_name, column_name, schema_date,
    column_seq, data_type, data_length,
    data_precision, data_scale, nullable,
    data_default, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task)(SELECT
     ac.table_name, ac.column_name, cnvtdatetime( $1),
     ac.column_seq, ac.data_type, ac.data_length,
     ac.data_precision, ac.data_scale, ac.nullable,
     ac.data_default, 0, cnvtdatetime(curdate,curtime3),
     0, 0, 0
     FROM dm_adm_columns ac
     WHERE ac.table_name=trim(list->tbl[x].table_name)
      AND ac.schema_date=cnvtdatetime(list->tbl[x].schema_date))
   ;end insert
   COMMIT
   FREE SET par_list
   RECORD par_list(
     1 qual[*]
       2 par_name = vc
     1 count = i4
   )
   SET par_list->count = 0
   SET stat = alterlist(par_list->qual,10)
   SELECT DISTINCT INTO "nl:"
    d.parent_table_name
    FROM dm_adm_constraints d
    WHERE d.table_name=trim(list->tbl[x].table_name)
     AND d.schema_date=cnvtdatetime(list->tbl[x].schema_date)
     AND d.constraint_type="R"
    DETAIL
     par_list->count = (par_list->count+ 1)
     IF (mod(par_list->count,10)=1)
      stat = alterlist(par_list->qual,(par_list->count+ 9))
     ENDIF
     par_list->qual[par_list->count].par_name = d.parent_table_name
    WITH nocounter
   ;end select
   SET knt = 0
   FOR (knt = 1 TO par_list->count)
     FREE SET r1
     RECORD r1(
       1 rdate = dq8
     )
     SET r1->rdate = 0
     SELECT DISTINCT INTO "nl:"
      d.schema_dt_tm
      FROM dm_feature_tables_env d
      WHERE (d.table_name=par_list->qual[knt].par_name)
       AND ((d.table_env_status="1") OR (d.table_env_status="S"))
      DETAIL
       IF ((d.schema_dt_tm > r1->rdate))
        r1->rdate = d.schema_dt_tm
       ENDIF
      WITH nocounter
     ;end select
     SET par_ind = 0
     IF ((r1->rdate > cnvtdatetime(list->tbl[x].schema_date)))
      SET par_ind = 1
     ENDIF
     IF (par_ind=1)
      FREE SET tbl_list
      RECORD tbl_list(
        1 qual[*]
          2 table_name = vc
          2 constraint_name = vc
          2 constraint_type = c5
          2 parent_table_name = vc
          2 status_ind = i2
          2 parent_table_columns = vc
          2 r_constraint_name = vc
        1 count = i4
      )
      SET tbl_list->count = 0
      SET stat = alterlist(tbl_list->qual,100)
      SELECT INTO "nl:"
       a.*
       FROM dm_adm_constraints a
       WHERE (a.table_name=list->tbl[x].table_name)
        AND datetimediff(a.schema_date,cnvtdatetime(r1->rdate))=0
        AND (a.parent_table_name=par_list->qual[knt].par_name)
       DETAIL
        tbl_list->count = (tbl_list->count+ 1)
        IF (mod(tbl_list->count,100)=1)
         stat = alterlist(tbl_list->qual,(tbl_list->count+ 99))
        ENDIF
        tbl_list->qual[tbl_list->count].table_name = a.table_name, tbl_list->qual[tbl_list->count].
        constraint_name = a.constraint_name, tbl_list->qual[tbl_list->count].constraint_type = a
        .constraint_type,
        tbl_list->qual[tbl_list->count].parent_table_name = a.parent_table_name, tbl_list->qual[
        tbl_list->count].status_ind = a.status_ind, tbl_list->qual[tbl_list->count].
        parent_table_columns = a.parent_table_columns,
        tbl_list->qual[tbl_list->count].r_constraint_name = a.r_constraint_name
       WITH nocounter
      ;end select
      FREE SET col_list
      RECORD col_list(
        1 qual[*]
          2 table_name = vc
          2 constraint_name = vc
          2 column_name = vc
          2 position = i2
        1 count = i4
      )
      SET stat2 = alterlist(col_list->qual,100)
      SET col_list->count = 0
      SELECT DISTINCT INTO "nl:"
       b.*
       FROM dm_adm_cons_columns b,
        dm_adm_constraints a
       WHERE (b.table_name=list->tbl[x].table_name)
        AND datetimediff(b.schema_date,cnvtdatetime(r1->rdate))=0
        AND b.table_name=a.table_name
        AND b.constraint_name=a.constraint_name
        AND (a.parent_table_name=par_list->qual[knt].par_name)
       DETAIL
        col_list->count = (col_list->count+ 1)
        IF (mod(col_list->count,100)=1)
         stat = alterlist(col_list->qual,(col_list->count+ 99))
        ENDIF
        col_list->qual[col_list->count].table_name = b.table_name, col_list->qual[col_list->count].
        constraint_name = b.constraint_name, col_list->qual[col_list->count].column_name = b
        .column_name,
        col_list->qual[col_list->count].position = b.position
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET kntt = 0
       SET valid_ind = 1
       FOR (kntt = 1 TO col_list->count)
         IF (valid_ind=1)
          SELECT INTO "nl:"
           c.*
           FROM dm_adm_columns c
           WHERE (c.table_name=list->tbl[x].table_name)
            AND (c.column_name=col_list->qual[kntt].column_name)
            AND c.schema_date=cnvtdatetime(list->tbl[x].schema_date)
           WITH nocounter
          ;end select
          IF (curqual > 0)
           SET valid_ind = 1
          ELSE
           SET valid_ind = 0
           SET par_ind = 0
          ENDIF
         ENDIF
       ENDFOR
       IF (valid_ind=1)
        SET knt1 = 0
        FOR (knt1 = 1 TO tbl_list->count)
          INSERT  FROM dm_constraints
           (table_name, schema_date, constraint_name,
           constraint_type, parent_table_name, status_ind,
           parent_table_columns, r_constraint_name, updt_applctx,
           updt_dt_tm, updt_cnt, updt_id,
           updt_task)
           VALUES(tbl_list->qual[knt1].table_name, cnvtdatetime( $1), tbl_list->qual[knt1].
           constraint_name,
           tbl_list->qual[knt1].constraint_type, tbl_list->qual[knt1].parent_table_name, tbl_list->
           qual[knt1].status_ind,
           tbl_list->qual[knt1].parent_table_columns, tbl_list->qual[knt1].r_constraint_name, 0,
           cnvtdatetime(curdate,curtime3), 0, 0,
           0)
           WITH nocounter
          ;end insert
        ENDFOR
        SET knt2 = 0
        FOR (knt2 = 1 TO col_list->count)
          INSERT  FROM dm_cons_columns
           (table_name, schema_date, constraint_name,
           column_name, position, updt_applctx,
           updt_dt_tm, updt_cnt, updt_id,
           updt_task)
           VALUES(col_list->qual[knt2].table_name, cnvtdatetime( $1), col_list->qual[knt2].
           constraint_name,
           col_list->qual[knt2].column_name, col_list->qual[knt2].position, 0,
           cnvtdatetime(curdate,curtime3), 0, 0,
           0)
           WITH nocounter
          ;end insert
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
     IF (par_ind=0)
      FREE SET tbl_list
      RECORD tbl_list(
        1 qual[*]
          2 table_name = vc
          2 constraint_name = vc
          2 constraint_type = c5
          2 parent_table_name = vc
          2 status_ind = i2
          2 parent_table_columns = vc
          2 r_constraint_name = vc
        1 count = i4
      )
      SET tbl_list->count = 0
      SET stat = alterlist(tbl_list->qual,100)
      SELECT INTO "nl:"
       a.*
       FROM dm_adm_constraints a
       WHERE (a.table_name=list->tbl[x].table_name)
        AND datetimediff(a.schema_date,cnvtdatetime(list->tbl[x].schema_date))=0
        AND (a.parent_table_name=par_list->qual[knt].par_name)
       DETAIL
        tbl_list->count = (tbl_list->count+ 1)
        IF (mod(tbl_list->count,100)=1)
         stat = alterlist(tbl_list->qual,(tbl_list->count+ 99))
        ENDIF
        tbl_list->qual[tbl_list->count].table_name = a.table_name, tbl_list->qual[tbl_list->count].
        constraint_name = a.constraint_name, tbl_list->qual[tbl_list->count].constraint_type = a
        .constraint_type,
        tbl_list->qual[tbl_list->count].parent_table_name = a.parent_table_name, tbl_list->qual[
        tbl_list->count].status_ind = a.status_ind, tbl_list->qual[tbl_list->count].
        parent_table_columns = a.parent_table_columns,
        tbl_list->qual[tbl_list->count].r_constraint_name = a.r_constraint_name
       WITH nocounter
      ;end select
      FREE SET par_col_list
      RECORD par_col_list(
        1 qual[*]
          2 column_name = vc
        1 count = i4
      )
      SET stat2 = alterlist(par_col_list->qual,100)
      SET par_col_list->count = 0
      SELECT DISTINCT INTO "nl:"
       b.column_name
       FROM dm_adm_cons_columns b,
        dm_adm_constraints a
       WHERE (b.table_name=par_list->qual[knt].par_name)
        AND (a.table_name=list->tbl[x].table_name)
        AND datetimediff(b.schema_date,cnvtdatetime(r1->rdate))=0
        AND datetimediff(a.schema_date,cnvtdatetime(list->tbl[x].schema_date))=0
        AND b.constraint_name=a.r_constraint_name
       ORDER BY b.position
       DETAIL
        par_col_list->count = (par_col_list->count+ 1)
        IF (mod(par_col_list->count,100)=1)
         stat = alterlist(par_col_list->qual,(par_col_list->count+ 99))
        ENDIF
        par_col_list->qual[par_col_list->count].column_name = b.column_name
       WITH nocounter
      ;end select
      SET kntt = 0
      SET col_string = fillstring(132," ")
      FOR (kntt = 1 TO par_col_list->count)
       IF (kntt > 1)
        SET col_string = build(col_string,",")
       ENDIF
       SET col_string = build(col_string,par_col_list->qual[kntt].column_name)
      ENDFOR
      SET term_ind = 1
      FOR (knt1 = 1 TO tbl_list->count)
        IF (trim(col_string)=trim(tbl_list->qual[knt1].parent_table_columns))
         SET term_ind = 0
        ENDIF
      ENDFOR
      IF (term_ind=0)
       INSERT  FROM dm_constraints
        (table_name, schema_date, constraint_name,
        constraint_type, parent_table_name, status_ind,
        parent_table_columns, r_constraint_name, updt_applctx,
        updt_dt_tm, updt_cnt, updt_id,
        updt_task)(SELECT
         ac.table_name, cnvtdatetime( $1), ac.constraint_name,
         ac.constraint_type, ac.parent_table_name, ac.status_ind,
         ac.parent_table_columns, ac.r_constraint_name, 0,
         cnvtdatetime(curdate,curtime3), 0, 0,
         0
         FROM dm_adm_constraints ac
         WHERE ac.table_name=trim(list->tbl[x].table_name)
          AND ac.parent_table_name=trim(par_list->qual[knt].par_name)
          AND ac.schema_date=cnvtdatetime(list->tbl[x].schema_date))
        WITH nocounter
       ;end insert
       INSERT  FROM dm_cons_columns
        (table_name, schema_date, constraint_name,
        column_name, position, updt_applctx,
        updt_dt_tm, updt_cnt, updt_id,
        updt_task)(SELECT
         acc.table_name, cnvtdatetime( $1), acc.constraint_name,
         acc.column_name, acc.position, 0,
         cnvtdatetime(curdate,curtime3), 0, 0,
         0
         FROM dm_adm_cons_columns acc,
          dm_adm_constraints ac
         WHERE acc.table_name=trim(list->tbl[x].table_name)
          AND acc.schema_date=cnvtdatetime(list->tbl[x].schema_date)
          AND ac.table_name=acc.table_name
          AND ac.schema_date=acc.schema_date
          AND ac.constraint_name=acc.constraint_name
          AND ac.parent_table_name=trim(par_list->qual[knt].par_name))
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
     COMMIT
   ENDFOR
   INSERT  FROM dm_constraints
    (table_name, schema_date, constraint_name,
    constraint_type, parent_table_name, status_ind,
    parent_table_columns, r_constraint_name, updt_applctx,
    updt_dt_tm, updt_cnt, updt_id,
    updt_task)(SELECT
     ac.table_name, cnvtdatetime( $1), ac.constraint_name,
     ac.constraint_type, ac.parent_table_name, ac.status_ind,
     ac.parent_table_columns, ac.r_constraint_name, 0,
     cnvtdatetime(curdate,curtime3), 0, 0,
     0
     FROM dm_adm_constraints ac
     WHERE ac.table_name=trim(list->tbl[x].table_name)
      AND ac.constraint_type IN ("P", "U")
      AND ac.schema_date=cnvtdatetime(list->tbl[x].schema_date))
    WITH nocounter
   ;end insert
   INSERT  FROM dm_cons_columns
    (table_name, schema_date, constraint_name,
    column_name, position, updt_applctx,
    updt_dt_tm, updt_cnt, updt_id,
    updt_task)(SELECT
     acc.table_name, cnvtdatetime( $1), acc.constraint_name,
     acc.column_name, acc.position, 0,
     cnvtdatetime(curdate,curtime3), 0, 0,
     0
     FROM dm_adm_cons_columns acc,
      dm_adm_constraints ac
     WHERE acc.table_name=trim(list->tbl[x].table_name)
      AND acc.schema_date=cnvtdatetime(list->tbl[x].schema_date)
      AND ac.table_name=acc.table_name
      AND ac.schema_date=acc.schema_date
      AND ac.constraint_name=acc.constraint_name
      AND ac.constraint_type IN ("P", "U"))
    WITH nocounter
   ;end insert
   COMMIT
   INSERT  FROM dm_indexes
    (index_name, schema_date, table_name,
    tablespace_name, pct_increase, pct_free,
    unique_ind, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task)(SELECT
     ai.index_name, cnvtdatetime( $1), ai.table_name,
     ai.tablespace_name, ai.pct_increase, ai.pct_free,
     ai.unique_ind, 0, cnvtdatetime(curdate,curtime3),
     0, 0, 0
     FROM dm_adm_indexes ai
     WHERE ai.table_name=trim(list->tbl[x].table_name)
      AND ai.schema_date=cnvtdatetime(list->tbl[x].schema_date))
   ;end insert
   COMMIT
   INSERT  FROM dm_index_columns
    (index_name, table_name, schema_date,
    column_name, column_position, updt_applctx,
    updt_dt_tm, updt_cnt, updt_id,
    updt_task)(SELECT
     aic.index_name, aic.table_name, cnvtdatetime( $1),
     aic.column_name, aic.column_position, 0,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), 0, 0,
     0
     FROM dm_adm_index_columns aic
     WHERE aic.table_name=trim(list->tbl[x].table_name)
      AND aic.schema_date=cnvtdatetime(list->tbl[x].schema_date))
   ;end insert
   COMMIT
 ENDFOR
END GO
