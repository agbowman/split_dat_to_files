CREATE PROGRAM dm_fill_afd_tables:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SET cdate = cnvtdatetime(curdate,curtime3)
 IF ((tab_list->count > 0))
  SET cnt = 0
  FOR (cnt = 1 TO tab_list->count)
    SET new_flag = 1
    SELECT DISTINCT INTO "nl:"
     a.table_name
     FROM dm_tables a
     WHERE (a.table_name=tab_list->qual[cnt].table_name)
      AND datetimediff(a.schema_date,cnvtdatetime(rev_date))=0
     DETAIL
      new_flag = 0
     WITH nocounter
    ;end select
    FREE SET r1
    RECORD r1(
      1 rdate = dq8
    )
    SET r1->rdate = 0
    SELECT INTO "NL:"
     dcf.schema_dt_tm
     FROM dm_feature_tables_env dcf
     WHERE (dcf.table_name=tab_list->qual[cnt].table_name)
      AND dcf.feature_number=fnumber
     DETAIL
      IF ((dcf.schema_dt_tm > r1->rdate))
       r1->rdate = dcf.schema_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual > 0)
     INSERT  FROM dm_afd_tables
      (table_name, alpha_feature_nbr, feature_number,
      tablespace_name, pct_increase, pct_used,
      pct_free, updt_applctx, updt_dt_tm,
      updt_cnt, updt_id, updt_task)(SELECT
       at.table_name, afd_nbr, fnumber,
       at.tablespace_name, at.pct_increase, at.pct_used,
       at.pct_free, 0, cnvtdatetime(cdate),
       0, 0, 0
       FROM dm_adm_tables at
       WHERE at.table_name=trim(tab_list->qual[cnt].table_name)
        AND at.schema_date=cnvtdatetime(r1->rdate))
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      at.*
      FROM dm_afd_tables at
      WHERE at.alpha_feature_nbr=afd_nbr
       AND (at.table_name=tab_list->qual[cnt].table_name)
      DETAIL
       tempstr = "insert into dm_afd_tables", tempstr, row + 1,
       tempstr =
       "(table_name, alpha_feature_nbr, feature_number,tablespace_name, pct_increase, pct_used,",
       tempstr, row + 1,
       tempstr = " pct_free, updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task )", tempstr, row
        + 1,
       tempstr = build('values("',at.table_name,'",',cnumber,",",
        fnumber,',"',at.tablespace_name,'",'), tempstr, row + 1,
       tempstr = build(at.pct_increase,",",at.pct_used,",",at.pct_free,
        ",",at.updt_applctx,","), tempstr, row + 1,
       tempstr = build('cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),',at.updt_cnt,",",
        at.updt_id,","), tempstr, row + 1,
       tempstr = build(at.updt_task,")  "), tempstr, row + 1,
       "with nocounter go", row + 1, "commit go ",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     IF (new_flag=0)
      INSERT  FROM dm_afd_columns
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
         AND ac.schema_date=cnvtdatetime(r1->rdate)
         AND ac.nullable="Y")
       WITH nocounter
      ;end insert
      INSERT  FROM dm_afd_columns
       (table_name, alpha_feature_nbr, column_name,
       column_seq, data_type, data_length,
       data_precision, data_scale, nullable,
       data_default, updt_applctx, updt_dt_tm,
       updt_cnt, updt_id, updt_task)(SELECT
        ac.table_name, afd_nbr, ac.column_name,
        ac.column_seq, ac.data_type, ac.data_length,
        ac.data_precision, ac.data_scale, d.nullable,
        ac.data_default, 0, cnvtdatetime(cdate),
        0, 0, 0
        FROM dm_adm_columns ac,
         dm_columns d
        WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
         AND ac.schema_date=cnvtdatetime(r1->rdate)
         AND ac.nullable="N"
         AND d.schema_date=cnvtdatetime(rev_date)
         AND d.table_name=ac.table_name
         AND ac.column_name=d.column_name
         AND  NOT ( EXISTS (
        (SELECT
         "X"
         FROM dm_afd_columns c,
          dm_alpha_features a
         WHERE c.table_name=ac.table_name
          AND c.column_name=ac.column_name
          AND a.alpha_feature_nbr=c.alpha_feature_nbr
          AND a.rev_number=rev_nbr
          AND c.nullable="Y"))))
       WITH nocounter
      ;end insert
      INSERT  FROM dm_afd_columns
       (table_name, alpha_feature_nbr, column_name,
       column_seq, data_type, data_length,
       data_precision, data_scale, nullable,
       data_default, updt_applctx, updt_dt_tm,
       updt_cnt, updt_id, updt_task)(SELECT
        ac.table_name, afd_nbr, ac.column_name,
        ac.column_seq, ac.data_type, ac.data_length,
        ac.data_precision, ac.data_scale, "Y",
        ac.data_default, 0, cnvtdatetime(cdate),
        0, 0, 0
        FROM dm_adm_columns ac
        WHERE ac.table_name=trim(tab_list->qual[cnt].table_name)
         AND ac.schema_date=cnvtdatetime(r1->rdate)
         AND ac.nullable="N"
         AND (( NOT ( EXISTS (
        (SELECT
         "X"
         FROM dm_columns d
         WHERE d.schema_date=cnvtdatetime(rev_date)
          AND d.table_name=ac.table_name
          AND d.column_name=ac.column_name)))) OR ( EXISTS (
        (SELECT
         "X"
         FROM dm_afd_columns c,
          dm_alpha_features a
         WHERE c.table_name=ac.table_name
          AND c.column_name=ac.column_name
          AND c.alpha_feature_nbr != afd_nbr
          AND a.alpha_feature_nbr=c.alpha_feature_nbr
          AND a.rev_number=rev_nbr
          AND c.nullable="Y")))) )
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM dm_afd_columns
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
         AND ac.schema_date=cnvtdatetime(r1->rdate))
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO value(fname)
      ac.*
      FROM dm_afd_columns ac
      WHERE ac.alpha_feature_nbr=afd_nbr
       AND (ac.table_name=tab_list->qual[cnt].table_name)
      DETAIL
       tempstr = "insert into dm_afd_columns ", tempstr, row + 1,
       tempstr = "(table_name,alpha_feature_nbr,column_name,column_seq,", tempstr, row + 1,
       tempstr = " data_type,data_length,data_precision,data_scale,", tempstr, row + 1,
       tempstr = " nullable,data_default,updt_applctx,", tempstr, row + 1,
       tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
       tempstr = build('values ("',ac.table_name,'",',cnumber,","), tempstr, row + 1,
       tempstr = build('"',ac.column_name,'",'), tempstr, row + 1,
       tempstr = build(ac.column_seq,',"',ac.data_type,'",',ac.data_length,
        ","), tempstr, row + 1,
       tempstr = build(ac.data_precision,",",ac.data_scale,',"',ac.nullable,
        '",'), tempstr, row + 1,
       tempstr = build('"',ac.data_default,'",'), tempstr, row + 1,
       tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'),
       tempstr, row + 1,
       tempstr = "with nocounter  go", tempstr, row + 1,
       "commit go ", row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_constraints
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
        AND ac.schema_date=cnvtdatetime(r1->rdate))
      WITH nocounter
     ;end insert
     INSERT  FROM dm_afd_constraints
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
        AND ac.schema_date=cnvtdatetime(r1->rdate))
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      ac.*
      FROM dm_afd_constraints ac
      WHERE ac.alpha_feature_nbr=afd_nbr
       AND (ac.table_name=tab_list->qual[cnt].table_name)
      DETAIL
       tempstr = "insert into dm_afd_constraints", tempstr, row + 1,
       tempstr = "(table_name,alpha_feature_nbr,constraint_name,", tempstr, row + 1,
       tempstr = " constraint_type,parent_table_name,status_ind,", tempstr, row + 1,
       tempstr = " parent_table_columns,r_constraint_name,updt_applctx,", tempstr, row + 1,
       tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
       tempstr = build('values ("',ac.table_name,'",'), tempstr, row + 1,
       tempstr = build(cnumber,","), tempstr, row + 1,
       tempstr = build('"',ac.constraint_name,'",'), tempstr, row + 1,
       tempstr = build('"',ac.constraint_type,'",'), tempstr, row + 1,
       tempstr = build('"',ac.parent_table_name,'",'), tempstr, row + 1,
       tempstr = build(ac.status_ind,","), tempstr, row + 1,
       tempstr = build('"',ac.parent_table_columns,'",'), tempstr, row + 1,
       tempstr = build('"',ac.r_constraint_name,'",'), tempstr, row + 1,
       tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'),
       tempstr, row + 1,
       "with nocounter go ", row + 1, "commit go ",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     INSERT  FROM dm_afd_cons_columns
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
        AND acc.schema_date=cnvtdatetime(r1->rdate)
        AND ac.table_name=acc.table_name
        AND ac.schema_date=acc.schema_date
        AND ac.constraint_name=acc.constraint_name)
      WITH nocounter
     ;end insert
     SELECT INTO value(fname)
      acc.*
      FROM dm_afd_cons_columns acc
      WHERE acc.alpha_feature_nbr=afd_nbr
       AND (acc.table_name=tab_list->qual[cnt].table_name)
      DETAIL
       tempstr = "insert into dm_afd_cons_columns", tempstr, row + 1,
       tempstr = "(table_name,alpha_feature_nbr,constraint_name,", tempstr, row + 1,
       tempstr = " column_name,position,updt_applctx,", tempstr, row + 1,
       tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
       tempstr = build('values ("',acc.table_name,'",'), tempstr, row + 1,
       tempstr = build(cnumber,","), tempstr, row + 1,
       tempstr = build('"',acc.constraint_name,'",'), tempstr, row + 1,
       tempstr = build('"',acc.column_name,'",'), tempstr, row + 1,
       tempstr = build(acc.position,","), tempstr, row + 1,
       tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0)'),
       tempstr, row + 1,
       "with nocounter go  ", row + 1, "commit go ",
       row + 2
      WITH nocounter, append, maxcol = 512,
       format = variable, formfeed = none, maxrow = 1
     ;end select
     SET ref_ind = 0
     SELECT INTO "nl:"
      a.reference_ind
      FROM dm_tables_doc a
      WHERE a.table_name=trim(tab_list->qual[cnt].table_name)
      DETAIL
       ref_ind = a.reference_ind
      WITH nocounter
     ;end select
     IF (ref_ind=1)
      INSERT  FROM dm_afd_indexes
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
         AND ai.schema_date=cnvtdatetime(r1->rdate))
      ;end insert
      SELECT INTO value(fname)
       ai.*
       FROM dm_afd_indexes ai
       WHERE ai.alpha_feature_nbr=afd_nbr
        AND (ai.table_name=tab_list->qual[cnt].table_name)
       DETAIL
        tempstr = "insert into dm_afd_indexes", tempstr, row + 1,
        tempstr = "(index_name,alpha_feature_nbr,table_name,tablespace_name,", tempstr, row + 1,
        tempstr = " pct_increase,pct_free,unique_ind,updt_applctx, ", tempstr, row + 1,
        tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
        tempstr = build('values ("',ai.index_name,'",'), tempstr, row + 1,
        tempstr = build(cnumber,","), tempstr, row + 1,
        tempstr = build('"',ai.table_name,'",'), tempstr, row + 1,
        tempstr = build('"',ai.tablespace_name,'",'), tempstr, row + 1,
        tempstr = build(ai.pct_increase,",",ai.pct_free,",",ai.unique_ind,
         ","), tempstr, row + 1,
        tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'),
        tempstr, row + 1,
        "with nocounter go ", row + 1, "commit go ",
        row + 2
       WITH nocounter, append, maxcol = 512,
        format = variable, formfeed = none, maxrow = 1
      ;end select
      INSERT  FROM dm_afd_index_columns
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
         AND aic.schema_date=cnvtdatetime(r1->rdate))
      ;end insert
      SELECT INTO value(fname)
       aic.*
       FROM dm_afd_index_columns aic
       WHERE aic.alpha_feature_nbr=afd_nbr
        AND (aic.table_name=tab_list->qual[cnt].table_name)
       DETAIL
        tempstr = "insert into dm_afd_index_columns", tempstr, row + 1,
        tempstr = "(index_name,table_name,alpha_feature_nbr,column_name,", tempstr, row + 1,
        tempstr = " column_position,updt_applctx,", tempstr, row + 1,
        tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
        tempstr = build('values ("',aic.index_name,'",'), tempstr, row + 1,
        tempstr = build('"',aic.table_name,'",'), tempstr, row + 1,
        tempstr = build(cnumber,","), tempstr, row + 1,
        tempstr = build('"',aic.column_name,'",'), tempstr, row + 1,
        tempstr = build(aic.column_position,","), tempstr, row + 1,
        tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 ) '),
        tempstr, row + 1,
        "with nocounter go ", row + 1, "commit go ",
        row + 2
       WITH nocounter, append, maxcol = 512,
        format = variable, formfeed = none, maxrow = 1
      ;end select
     ELSE
      IF (new_flag=0)
       INSERT  FROM dm_afd_indexes
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
          AND ai.schema_date=cnvtdatetime(rev_date))
       ;end insert
      ELSE
       INSERT  FROM dm_afd_indexes
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
          AND ai.schema_date=cnvtdatetime(r1->rdate))
       ;end insert
      ENDIF
      SELECT INTO value(fname)
       ai.*
       FROM dm_afd_indexes ai
       WHERE ai.alpha_feature_nbr=afd_nbr
        AND (ai.table_name=tab_list->qual[cnt].table_name)
       DETAIL
        tempstr = "insert into dm_afd_indexes", tempstr, row + 1,
        tempstr = "(index_name,alpha_feature_nbr,table_name,tablespace_name,", tempstr, row + 1,
        tempstr = " pct_increase,pct_free,unique_ind,updt_applctx, ", tempstr, row + 1,
        tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
        tempstr = build('values ("',ai.index_name,'",'), tempstr, row + 1,
        tempstr = build(cnumber,","), tempstr, row + 1,
        tempstr = build('"',ai.table_name,'",'), tempstr, row + 1,
        tempstr = build('"',ai.tablespace_name,'",'), tempstr, row + 1,
        tempstr = build(ai.pct_increase,",",ai.pct_free,",",ai.unique_ind,
         ","), tempstr, row + 1,
        tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 )'),
        tempstr, row + 1,
        "with nocounter go ", row + 1, "commit go ",
        row + 2
       WITH nocounter, append, maxcol = 512,
        format = variable, formfeed = none, maxrow = 1
      ;end select
      IF (new_flag=0)
       INSERT  FROM dm_afd_index_columns
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
          AND aic.schema_date=cnvtdatetime(rev_date))
       ;end insert
      ELSE
       INSERT  FROM dm_afd_index_columns
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
          AND aic.schema_date=cnvtdatetime(r1->rdate))
       ;end insert
      ENDIF
      SELECT INTO value(fname)
       aic.*
       FROM dm_afd_index_columns aic
       WHERE aic.alpha_feature_nbr=afd_nbr
        AND (aic.table_name=tab_list->qual[cnt].table_name)
       DETAIL
        tempstr = "insert into dm_afd_index_columns", tempstr, row + 1,
        tempstr = "(index_name,table_name,alpha_feature_nbr,column_name,", tempstr, row + 1,
        tempstr = " column_position,updt_applctx,", tempstr, row + 1,
        tempstr = " updt_dt_tm,updt_cnt,updt_id,updt_task)", tempstr, row + 1,
        tempstr = build('values ("',aic.index_name,'",'), tempstr, row + 1,
        tempstr = build('"',aic.table_name,'",'), tempstr, row + 1,
        tempstr = build(cnumber,","), tempstr, row + 1,
        tempstr = build('"',aic.column_name,'",'), tempstr, row + 1,
        tempstr = build(aic.column_position,","), tempstr, row + 1,
        tempstr = build('0,cnvtdatetime("',format(cdate,"dd-mmm-yyyy hh:mm:ss;;D"),'"),0,0,0 ) '),
        tempstr, row + 1,
        "with nocounter go ", row + 1, "commit go ",
        row + 2
       WITH nocounter, append, maxcol = 512,
        format = variable, formfeed = none, maxrow = 1
      ;end select
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 COMMIT
END GO
