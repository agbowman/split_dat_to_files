CREATE PROGRAM dm_ocd_get_table_schema:dba
 RECORD reply(
   1 old_ocd_number = i4
   1 f_col_cnt = i4
   1 f_cols[*]
     2 column_name = c30
     2 data_type = c9
     2 data_length = i4
     2 nullable = c1
     2 data_default = vc
     2 new_ind = i2
     2 diff_ind = i2
   1 f_cons_cnt = i4
   1 f_cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 parent_table_name = c30
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
   1 f_ind_cnt = i4
   1 f_ind[*]
     2 index_name = c30
     2 unique_ind = i2
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
   1 b_col_cnt = i4
   1 b_cols[*]
     2 column_name = c30
     2 data_type = c9
     2 data_length = i4
     2 nullable = c1
     2 data_default = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 b_cons_cnt = i4
   1 b_cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 parent_table_name = c30
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 b_ind_cnt = i4
   1 b_ind[*]
     2 index_name = c30
     2 unique_ind = i2
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 o_col_cnt = i4
   1 o_cols[*]
     2 column_name = c30
     2 data_type = c9
     2 data_length = i4
     2 nullable = c1
     2 data_default = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 o_cons_cnt = i4
   1 o_cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 parent_table_name = c30
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 o_ind_cnt = i4
   1 o_ind[*]
     2 index_name = c30
     2 unique_ind = i2
     2 columns = vc
     2 new_ind = i2
     2 diff_ind = i2
     2 cmb_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->old_ocd_number = 0
 SET reply->f_col_cnt = 0
 SET stat = alterlist(reply->f_cols,0)
 SET reply->f_cons_cnt = 0
 SET stat = alterlist(reply->f_cons,0)
 SET reply->f_ind_cnt = 0
 SET stat = alterlist(reply->f_ind,0)
 SET reply->b_col_cnt = 0
 SET stat = alterlist(reply->b_cols,0)
 SET reply->b_cons_cnt = 0
 SET stat = alterlist(reply->b_cons,0)
 SET reply->b_ind_cnt = 0
 SET stat = alterlist(reply->b_ind,0)
 SET reply->o_col_cnt = 0
 SET stat = alterlist(reply->o_cols,0)
 SET reply->o_cons_cnt = 0
 SET stat = alterlist(reply->o_cons,0)
 SET reply->o_ind_cnt = 0
 SET stat = alterlist(reply->o_ind,0)
 SET reply->status_data.status = "F"
 SET dm_debug = 0
 IF (validate(dm_ocd_debug,- (1)) > 0)
  SET dm_debug = dm_ocd_debug
 ENDIF
 IF (dm_debug=1)
  CALL echo("***")
  CALL echorecord(request)
  CALL echo("***")
 ENDIF
 FREE RECORD cmb_tables
 RECORD cmb_tables(
   1 tbl_cnt = i4
   1 tbl[*]
     2 tbl_name = vc
     2 cons_ind = i2
     2 indx_ind = i2
 )
 SET cmb_tables->tbl_cnt = 0
 SET stat = alterlist(cmb_tables->tbl,0)
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "PERSON"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 1
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "ENCOUNTER"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 1
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "LOCATION"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 0
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "HEALTH_PLAN"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 0
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "ORGANIZATION"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 0
 SET cmb_tables->tbl_cnt = (cmb_tables->tbl_cnt+ 1)
 SET stat = alterlist(cmb_tables->tbl,cmb_tables->tbl_cnt)
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].tbl_name = "PRSNL"
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].cons_ind = 1
 SET cmb_tables->tbl[cmb_tables->tbl_cnt].indx_ind = 0
 FREE RECORD sch
 RECORD sch(
   1 f_cons_cnt = i4
   1 f_cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 col_pos = i4
   1 f_ind_cnt = i4
   1 f_ind[*]
     2 index_name = c30
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 col_pos = i4
   1 o_cons_cnt = i4
   1 o_cons[*]
     2 constraint_name = c30
     2 constraint_type = c1
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 col_pos = i4
   1 o_ind_cnt = i4
   1 o_ind[*]
     2 index_name = c30
     2 col_cnt = i4
     2 cols[*]
       3 column_name = c30
       3 col_pos = i4
 )
 SET sch->f_cons_cnt = 0
 SET stat = alterlist(sch->f_cons,0)
 SET sch->f_ind_cnt = 0
 SET stat = alterlist(sch->f_ind,0)
 SET sch->o_cons_cnt = 0
 SET stat = alterlist(sch->o_cons,0)
 SET sch->o_ind_cnt = 0
 SET stat = alterlist(sch->o_ind,0)
 FREE RECORD dm_date
 RECORD dm_date(
   1 adm_schema_date = dq8
   1 rev_schema_date = dq8
   1 ocd_schema_date = dq8
 )
 SET old_ocd_number = 0
 SET new_table_ind = 0
 SET ocd_edit_ind = 0
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 SELECT INTO "nl:"
  d.table_name, d.feature_number, d.schema_dt_tm
  FROM dm_feature_tables_env d
  WHERE (d.table_name=request->table_name)
   AND (d.feature_number=request->feature_number)
  ORDER BY d.schema_dt_tm
  DETAIL
   dm_date->adm_schema_date = d.schema_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.proj_name, d.feature, d.schema_date
  FROM dm_project_status_env d
  WHERE (d.proj_name=request->table_name)
   AND (d.feature=request->feature_number)
  ORDER BY d.schema_date
  DETAIL
   IF ((d.schema_date > dm_date->adm_schema_date))
    dm_date->adm_schema_date = d.schema_date
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_debug=1)
  CALL echo("***")
  CALL echo(build("*** adm_schema_date=",format(dm_date->adm_schema_date,"DD-MMM-YYYY HH:MM:SS;;Q")))
  CALL echo("*** Fill the f_ list with feature schema")
  CALL echo("***")
 ENDIF
 SELECT INTO "nl:"
  d.*, def_is_null = nullind(d.data_default)
  FROM dm_adm_columns d
  WHERE (d.table_name=request->table_name)
   AND d.schema_date=cnvtdatetime(dm_date->adm_schema_date)
  ORDER BY d.column_name
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->f_col_cnt = cnt, stat = alterlist(reply->f_cols,cnt),
   reply->f_cols[cnt].column_name = d.column_name, reply->f_cols[cnt].data_type = d.data_type, reply
   ->f_cols[cnt].data_length = d.data_length,
   reply->f_cols[cnt].nullable = d.nullable
   IF (def_is_null=1)
    reply->f_cols[cnt].data_default = "NULL"
   ELSE
    reply->f_cols[cnt].data_default = build(d.data_default)
   ENDIF
   reply->f_cols[cnt].new_ind = 1, reply->f_cols[cnt].diff_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.*, c.*
  FROM dm_adm_cons_columns d,
   dm_adm_constraints c
  WHERE (c.table_name=request->table_name)
   AND c.schema_date=cnvtdatetime(dm_date->adm_schema_date)
   AND d.table_name=c.table_name
   AND d.schema_date=c.schema_date
   AND d.constraint_name=c.constraint_name
  ORDER BY d.constraint_name, d.position
  HEAD REPORT
   cnt = 0
  HEAD d.constraint_name
   cnt = (cnt+ 1), reply->f_cons_cnt = cnt, stat = alterlist(reply->f_cons,cnt),
   reply->f_cons[cnt].constraint_name = d.constraint_name, reply->f_cons[cnt].constraint_type = c
   .constraint_type
   IF (c.constraint_type="R")
    reply->f_cons[cnt].parent_table_name = c.parent_table_name
   ELSE
    reply->f_cons[cnt].parent_table_name = ""
   ENDIF
   reply->f_cons[cnt].new_ind = 1, reply->f_cons[cnt].diff_ind = 0, reply->f_cons[cnt].columns = "",
   col_cnt = 0, sch->f_cons_cnt = cnt, stat = alterlist(sch->f_cons,cnt),
   sch->f_cons[cnt].constraint_name = d.constraint_name, sch->f_cons[cnt].col_cnt = 0, stat =
   alterlist(sch->f_cons[cnt].cols,0)
  DETAIL
   col_cnt = (col_cnt+ 1)
   IF (col_cnt=1)
    reply->f_cons[cnt].columns = build(d.column_name)
   ELSE
    reply->f_cons[cnt].columns = build(reply->f_cons[cnt].columns,",",d.column_name)
   ENDIF
   sch->f_cons[cnt].col_cnt = col_cnt, stat = alterlist(sch->f_cons[cnt].cols,col_cnt), sch->f_cons[
   cnt].cols[col_cnt].column_name = d.column_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.*, i.*
  FROM dm_adm_index_columns d,
   dm_adm_indexes i
  WHERE (i.table_name=request->table_name)
   AND i.schema_date=cnvtdatetime(dm_date->adm_schema_date)
   AND d.table_name=i.table_name
   AND d.schema_date=i.schema_date
   AND d.index_name=i.index_name
  ORDER BY d.index_name, d.column_position
  HEAD REPORT
   cnt = 0
  HEAD d.index_name
   cnt = (cnt+ 1), reply->f_ind_cnt = cnt, stat = alterlist(reply->f_ind,cnt),
   reply->f_ind[cnt].index_name = d.index_name, reply->f_ind[cnt].unique_ind = i.unique_ind, reply->
   f_ind[cnt].new_ind = 1,
   reply->f_ind[cnt].diff_ind = 0, reply->f_ind[cnt].columns = "", col_cnt = 0,
   sch->f_ind_cnt = cnt, stat = alterlist(sch->f_ind,cnt), sch->f_ind[cnt].index_name = d.index_name,
   sch->f_ind[cnt].col_cnt = 0, stat = alterlist(sch->f_ind[cnt].cols,0)
  DETAIL
   col_cnt = (col_cnt+ 1)
   IF (col_cnt=1)
    reply->f_ind[cnt].columns = build(d.column_name)
   ELSE
    reply->f_ind[cnt].columns = build(reply->f_ind[cnt].columns,",",d.column_name)
   ENDIF
   sch->f_ind[cnt].col_cnt = col_cnt, stat = alterlist(sch->f_ind[cnt].cols,col_cnt), sch->f_ind[cnt]
   .cols[col_cnt].column_name = d.column_name
  WITH nocounter
 ;end select
 IF (dm_debug=1)
  CALL echo("***")
  CALL echo("*** Check if this table was shipped on previous OCD")
  CALL echo("***")
 ENDIF
 SELECT INTO "nl:"
  dt.table_name, dt.alpha_feature_nbr, dt.schema_date
  FROM dm_alpha_features df,
   dm_afd_tables dt
  PLAN (df
   WHERE (df.rev_number=request->rev_number))
   JOIN (dt
   WHERE (dt.table_name=request->table_name)
    AND dt.alpha_feature_nbr=df.alpha_feature_nbr)
  ORDER BY dt.schema_date
  DETAIL
   dm_date->ocd_schema_date = dt.schema_date, old_ocd_number = dt.alpha_feature_nbr
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET old_ocd_number = 0
 ENDIF
 SET reply->old_ocd_number = old_ocd_number
 IF (old_ocd_number > 0)
  IF (dm_debug=1)
   CALL echo("***")
   CALL echo(build("*** old_ocd_number=",old_ocd_number))
   IF ((old_ocd_number=request->ocd_number))
    SET ocd_edit_ind = 1
    CALL echo("*** ocd_edit_ind=1")
   ENDIF
   CALL echo("***")
  ENDIF
 ELSE
  IF (dm_debug=1)
   CALL echo("***")
   CALL echo("*** Check if this table was shipped in Base Rev")
   CALL echo("***")
  ENDIF
  SELECT INTO "nl:"
   d.schema_version"##.###", d.schema_date
   FROM dm_schema_version d
   WHERE (d.schema_version=request->rev_number)
   DETAIL
    dm_date->rev_schema_date = d.schema_date
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_tables d
   WHERE (d.table_name=request->table_name)
    AND d.schema_date=cnvtdatetime(dm_date->rev_schema_date)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET new_table_ind = 1
   IF (dm_debug=1)
    CALL echo("***")
    CALL echo("*** Not in base rev either! This is a new table.")
    CALL echo("***")
   ENDIF
  ENDIF
 ENDIF
 IF (new_table_ind=0)
  IF (dm_debug=1)
   IF (old_ocd_number > 0)
    CALL echo("***")
    CALL echo("*** Get the schema for o_ list from old_ocd_number")
    CALL echo("***")
   ELSE
    CALL echo("***")
    CALL echo("*** Get the schema for o_ list from base rev")
    CALL echo("***")
   ENDIF
  ENDIF
  SELECT
   IF (old_ocd_number > 0)
    def_is_null = nullind(d.data_default)
    FROM dm_afd_columns d
    WHERE (d.table_name=request->table_name)
     AND d.alpha_feature_nbr=old_ocd_number
    ORDER BY d.column_name
   ELSE
    def_is_null = nullind(d.data_default)
    FROM dm_columns d
    WHERE (d.table_name=request->table_name)
     AND d.schema_date=cnvtdatetime(dm_date->rev_schema_date)
    ORDER BY d.column_name
   ENDIF
   INTO "nl:"
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), reply->o_col_cnt = cnt, stat = alterlist(reply->o_cols,cnt),
    reply->o_cols[cnt].column_name = d.column_name, reply->o_cols[cnt].data_type = d.data_type, reply
    ->o_cols[cnt].data_length = d.data_length,
    reply->o_cols[cnt].nullable = d.nullable
    IF (def_is_null=1)
     reply->o_cols[cnt].data_default = "NULL"
    ELSE
     reply->o_cols[cnt].data_default = build(d.data_default)
    ENDIF
    reply->o_cols[cnt].new_ind = 0, reply->o_cols[cnt].diff_ind = 0, reply->o_cols[cnt].cmb_ind = 0
   WITH nocounter
  ;end select
  SELECT
   IF (old_ocd_number > 0)
    FROM dm_afd_cons_columns d,
     dm_afd_constraints c
    WHERE (c.table_name=request->table_name)
     AND c.alpha_feature_nbr=old_ocd_number
     AND d.table_name=c.table_name
     AND d.alpha_feature_nbr=c.alpha_feature_nbr
     AND d.constraint_name=c.constraint_name
    ORDER BY d.constraint_name, d.position
   ELSE
    FROM dm_cons_columns d,
     dm_constraints c
    WHERE (c.table_name=request->table_name)
     AND c.schema_date=cnvtdatetime(dm_date->rev_schema_date)
     AND d.table_name=c.table_name
     AND d.schema_date=c.schema_date
     AND d.constraint_name=c.constraint_name
    ORDER BY d.constraint_name, d.position
   ENDIF
   INTO "nl:"
   HEAD REPORT
    cnt = 0
   HEAD d.constraint_name
    cnt = (cnt+ 1), reply->o_cons_cnt = cnt, stat = alterlist(reply->o_cons,cnt),
    reply->o_cons[cnt].constraint_name = d.constraint_name, reply->o_cons[cnt].constraint_type = c
    .constraint_type
    IF (c.constraint_type="R")
     reply->o_cons[cnt].parent_table_name = c.parent_table_name
    ELSE
     reply->o_cons[cnt].parent_table_name = ""
    ENDIF
    reply->o_cons[cnt].new_ind = 0, reply->o_cons[cnt].diff_ind = 0, reply->o_cons[cnt].cmb_ind = 0,
    reply->o_cons[cnt].columns = "", col_cnt = 0, sch->o_cons_cnt = cnt,
    stat = alterlist(sch->o_cons,cnt), sch->o_cons[cnt].constraint_name = d.constraint_name, sch->
    o_cons[cnt].col_cnt = 0,
    stat = alterlist(sch->o_cons[cnt].cols,0)
   DETAIL
    col_cnt = (col_cnt+ 1)
    IF (col_cnt=1)
     reply->o_cons[cnt].columns = build(d.column_name)
    ELSE
     reply->o_cons[cnt].columns = build(reply->o_cons[cnt].columns,",",d.column_name)
    ENDIF
    sch->o_cons[cnt].col_cnt = col_cnt, stat = alterlist(sch->o_cons[cnt].cols,col_cnt), sch->o_cons[
    cnt].cols[col_cnt].column_name = d.column_name
   WITH nocounter
  ;end select
  SELECT
   IF (old_ocd_number > 0)
    FROM dm_afd_index_columns d,
     dm_afd_indexes i
    WHERE (i.table_name=request->table_name)
     AND i.alpha_feature_nbr=old_ocd_number
     AND d.table_name=i.table_name
     AND d.alpha_feature_nbr=i.alpha_feature_nbr
     AND d.index_name=i.index_name
    ORDER BY d.index_name, d.column_position
   ELSE
    FROM dm_index_columns d,
     dm_indexes i
    WHERE (i.table_name=request->table_name)
     AND i.schema_date=cnvtdatetime(dm_date->rev_schema_date)
     AND d.table_name=i.table_name
     AND d.schema_date=i.schema_date
     AND d.index_name=i.index_name
    ORDER BY d.index_name, d.column_position
   ENDIF
   INTO "nl:"
   HEAD REPORT
    cnt = 0
   HEAD d.index_name
    cnt = (cnt+ 1), reply->o_ind_cnt = cnt, stat = alterlist(reply->o_ind,cnt),
    reply->o_ind[cnt].index_name = d.index_name, reply->o_ind[cnt].unique_ind = i.unique_ind, reply->
    o_ind[cnt].new_ind = 0,
    reply->o_ind[cnt].diff_ind = 0, reply->o_ind[cnt].cmb_ind = 0, reply->o_ind[cnt].columns = "",
    col_cnt = 0, sch->o_ind_cnt = cnt, stat = alterlist(sch->o_ind,cnt),
    sch->o_ind[cnt].index_name = d.index_name, sch->o_ind[cnt].col_cnt = 0, stat = alterlist(sch->
     o_ind[cnt].cols,0)
   DETAIL
    col_cnt = (col_cnt+ 1)
    IF (col_cnt=1)
     reply->o_ind[cnt].columns = build(d.column_name)
    ELSE
     reply->o_ind[cnt].columns = build(reply->o_ind[cnt].columns,",",d.column_name)
    ENDIF
    sch->o_ind[cnt].col_cnt = col_cnt, stat = alterlist(sch->o_ind[cnt].cols,col_cnt), sch->o_ind[cnt
    ].cols[col_cnt].column_name = d.column_name
   WITH nocounter
  ;end select
 ELSE
  IF (old_ocd_number=0)
   IF (dm_debug=1)
    CALL echo("***")
    CALL echo("*** Make the schema on this OCD equal to feature schema")
    CALL echo("***")
   ENDIF
   IF ((reply->f_col_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(reply->f_col_cnt))
     ORDER BY d.seq
     HEAD REPORT
      reply->o_col_cnt = reply->f_col_cnt, stat = alterlist(reply->o_cols,reply->o_col_cnt)
     DETAIL
      reply->o_cols[d.seq].column_name = reply->f_cols[d.seq].column_name, reply->o_cols[d.seq].
      data_type = reply->f_cols[d.seq].data_type, reply->o_cols[d.seq].data_length = reply->f_cols[d
      .seq].data_length,
      reply->o_cols[d.seq].nullable = reply->f_cols[d.seq].nullable, reply->o_cols[d.seq].
      data_default = reply->f_cols[d.seq].data_default, reply->o_cols[d.seq].new_ind = reply->f_cols[
      d.seq].new_ind,
      reply->o_cols[d.seq].diff_ind = reply->f_cols[d.seq].diff_ind, reply->o_cols[d.seq].cmb_ind = 0
     WITH nocounter
    ;end select
   ENDIF
   IF ((reply->f_cons_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(reply->f_cons_cnt))
     ORDER BY d.seq
     HEAD REPORT
      reply->o_cons_cnt = reply->f_cons_cnt, stat = alterlist(reply->o_cons,reply->o_cons_cnt), sch->
      o_cons_cnt = reply->f_cons_cnt,
      stat = alterlist(sch->o_cons,reply->f_cons_cnt)
     DETAIL
      reply->o_cons[d.seq].constraint_name = reply->f_cons[d.seq].constraint_name, reply->o_cons[d
      .seq].constraint_type = reply->f_cons[d.seq].constraint_type, reply->o_cons[d.seq].
      parent_table_name = reply->f_cons[d.seq].parent_table_name,
      reply->o_cons[d.seq].columns = reply->f_cons[d.seq].columns, reply->o_cons[d.seq].new_ind =
      reply->f_cons[d.seq].new_ind, reply->o_cons[d.seq].diff_ind = reply->f_cons[d.seq].diff_ind,
      reply->o_cons[d.seq].cmb_ind = 0, done = 0, cnt = 0,
      start_pos = 1, pos = findstring(",",reply->f_cons[d.seq].columns,start_pos)
      WHILE (done=0)
        IF (pos=0)
         len = ((size(reply->f_cons[d.seq].columns,1) - start_pos)+ 1), done = 1
        ELSE
         len = (pos - start_pos)
        ENDIF
        cnt = (cnt+ 1), sch->o_cons[d.seq].col_cnt = cnt, stat = alterlist(sch->o_cons[d.seq].cols,
         cnt),
        sch->o_cons[d.seq].cols[cnt].column_name = substring(start_pos,len,reply->f_cons[d.seq].
         columns), sch->o_cons[d.seq].cols[cnt].col_pos = cnt, start_pos = (pos+ 1),
        pos = findstring(",",reply->f_cons[d.seq].columns,start_pos)
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
   IF ((reply->f_ind_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(reply->f_ind_cnt))
     ORDER BY d.seq
     HEAD REPORT
      reply->o_ind_cnt = reply->f_ind_cnt, stat = alterlist(reply->o_ind,reply->o_ind_cnt), sch->
      o_ind_cnt = reply->f_ind_cnt,
      stat = alterlist(sch->o_ind,reply->f_ind_cnt)
     DETAIL
      reply->o_ind[d.seq].index_name = reply->f_ind[d.seq].index_name, reply->o_ind[d.seq].unique_ind
       = reply->f_ind[d.seq].unique_ind, reply->o_ind[d.seq].columns = reply->f_ind[d.seq].columns,
      reply->o_ind[d.seq].new_ind = reply->f_ind[d.seq].new_ind, reply->o_ind[d.seq].diff_ind = reply
      ->f_ind[d.seq].diff_ind, reply->o_ind[d.seq].cmb_ind = 0,
      done = 0, cnt = 0, start_pos = 1,
      pos = findstring(",",reply->f_ind[d.seq].columns,start_pos)
      WHILE (done=0)
        IF (pos=0)
         len = ((size(reply->f_ind[d.seq].columns,1) - start_pos)+ 1), done = 1
        ELSE
         len = (pos - start_pos)
        ENDIF
        cnt = (cnt+ 1), sch->o_ind[d.seq].col_cnt = cnt, stat = alterlist(sch->o_ind[d.seq].cols,cnt),
        sch->o_ind[d.seq].cols[cnt].column_name = substring(start_pos,len,reply->f_ind[d.seq].columns
         ), sch->o_ind[d.seq].cols[cnt].col_pos = cnt, start_pos = (pos+ 1),
        pos = findstring(",",reply->f_ind[d.seq].columns,start_pos)
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   IF (dm_debug=1)
    CALL echo("***")
    CALL echo("*** Make the schema on this OCD equal to old_ocd_number")
    CALL echo("***")
   ENDIF
   SELECT INTO "nl:"
    def_is_null = nullind(d.data_default)
    FROM dm_afd_columns d
    WHERE (d.table_name=request->table_name)
     AND d.alpha_feature_nbr=old_ocd_number
    ORDER BY d.column_name
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), reply->o_col_cnt = cnt, stat = alterlist(reply->o_cols,cnt),
     reply->o_cols[cnt].column_name = d.column_name, reply->o_cols[cnt].data_type = d.data_type,
     reply->o_cols[cnt].data_length = d.data_length,
     reply->o_cols[cnt].nullable = d.nullable
     IF (def_is_null=1)
      reply->o_cols[cnt].data_default = "NULL"
     ELSE
      reply->o_cols[cnt].data_default = build(d.data_default)
     ENDIF
     reply->o_cols[cnt].new_ind = 0, reply->o_cols[cnt].diff_ind = 0, reply->o_cols[cnt].cmb_ind = 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_afd_cons_columns d,
     dm_afd_constraints c
    WHERE (c.table_name=request->table_name)
     AND c.alpha_feature_nbr=old_ocd_number
     AND d.table_name=c.table_name
     AND d.alpha_feature_nbr=c.alpha_feature_nbr
     AND d.constraint_name=c.constraint_name
    ORDER BY d.constraint_name, d.position
    HEAD REPORT
     cnt = 0
    HEAD d.constraint_name
     cnt = (cnt+ 1), reply->o_cons_cnt = cnt, stat = alterlist(reply->o_cons,cnt),
     reply->o_cons[cnt].constraint_name = d.constraint_name, reply->o_cons[cnt].constraint_type = c
     .constraint_type
     IF (c.constraint_type="R")
      reply->o_cons[cnt].parent_table_name = c.parent_table_name
     ELSE
      reply->o_cons[cnt].parent_table_name = ""
     ENDIF
     reply->o_cons[cnt].new_ind = 0, reply->o_cons[cnt].diff_ind = 0, reply->o_cons[cnt].cmb_ind = 0,
     reply->o_cons[cnt].columns = "", col_cnt = 0, sch->o_cons_cnt = cnt,
     stat = alterlist(sch->o_cons,cnt), sch->o_cons[cnt].constraint_name = d.constraint_name, sch->
     o_cons[cnt].col_cnt = 0,
     stat = alterlist(sch->o_cons[cnt].cols,0)
    DETAIL
     col_cnt = (col_cnt+ 1)
     IF (col_cnt=1)
      reply->o_cons[cnt].columns = build(d.column_name)
     ELSE
      reply->o_cons[cnt].columns = build(reply->o_cons[cnt].columns,",",d.column_name)
     ENDIF
     sch->o_cons[cnt].col_cnt = col_cnt, stat = alterlist(sch->o_cons[cnt].cols,col_cnt), sch->
     o_cons[cnt].cols[col_cnt].column_name = d.column_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_afd_index_columns d,
     dm_afd_indexes i
    WHERE (i.table_name=request->table_name)
     AND i.alpha_feature_nbr=old_ocd_number
     AND d.table_name=i.table_name
     AND d.alpha_feature_nbr=i.alpha_feature_nbr
     AND d.index_name=i.index_name
    ORDER BY d.index_name, d.column_position
    HEAD REPORT
     cnt = 0
    HEAD d.index_name
     cnt = (cnt+ 1), reply->o_ind_cnt = cnt, stat = alterlist(reply->o_ind,cnt),
     reply->o_ind[cnt].index_name = d.index_name, reply->o_ind[cnt].unique_ind = i.unique_ind, reply
     ->o_ind[cnt].new_ind = 0,
     reply->o_ind[cnt].diff_ind = 0, reply->o_ind[cnt].cmb_ind = 0, reply->o_ind[cnt].columns = "",
     col_cnt = 0, sch->o_ind_cnt = cnt, stat = alterlist(sch->o_ind,cnt),
     sch->o_ind[cnt].index_name = d.index_name, sch->o_ind[cnt].col_cnt = 0, stat = alterlist(sch->
      o_ind[cnt].cols,0)
    DETAIL
     col_cnt = (col_cnt+ 1)
     IF (col_cnt=1)
      reply->o_ind[cnt].columns = build(d.column_name)
     ELSE
      reply->o_ind[cnt].columns = build(reply->o_ind[cnt].columns,",",d.column_name)
     ENDIF
     sch->o_ind[cnt].col_cnt = col_cnt, stat = alterlist(sch->o_ind[cnt].cols,col_cnt), sch->o_ind[
     cnt].cols[col_cnt].column_name = d.column_name
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (((new_table_ind=0) OR (old_ocd_number > 0)) )
  IF (dm_debug=1)
   CALL echo("***")
   CALL echo("*** This table was shipped in Base Rev or Previous OCD.")
   CALL echo("*** Compare this OCD schema with schema on feature to")
   CALL echo("*** set the new_ind and diff_ind for objects.")
   IF (old_ocd_number=0)
    CALL echo(build("*** rev_schema_date=",format(dm_date->rev_schema_date,"DD-MMM-YYYY;;D")))
   ELSE
    CALL echo(build("*** old_ocd_number=",old_ocd_number))
   ENDIF
   CALL echo("***")
  ENDIF
  IF ((reply->f_col_cnt > 0)
   AND (reply->o_col_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt f  WITH seq = value(reply->f_col_cnt)),
     (dummyt o  WITH seq = value(reply->o_col_cnt))
    PLAN (f)
     JOIN (o
     WHERE (reply->f_cols[f.seq].column_name=reply->o_cols[o.seq].column_name))
    DETAIL
     IF ((((reply->f_cols[f.seq].data_type != reply->o_cols[o.seq].data_type)) OR ((((reply->f_cols[f
     .seq].data_length != reply->o_cols[o.seq].data_length)) OR ((((reply->f_cols[f.seq].nullable !=
     reply->o_cols[o.seq].nullable)) OR ((reply->f_cols[f.seq].data_default != reply->o_cols[o.seq].
     data_default))) )) )) )
      reply->f_cols[f.seq].diff_ind = 1
     ENDIF
     reply->f_cols[f.seq].new_ind = 0, reply->o_cols[o.seq].new_ind = reply->f_cols[f.seq].new_ind,
     reply->o_cols[o.seq].diff_ind = reply->f_cols[f.seq].diff_ind
    WITH nocounter
   ;end select
  ENDIF
  IF ((reply->f_cons_cnt > 0)
   AND (reply->o_cons_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt f  WITH seq = value(reply->f_cons_cnt)),
     (dummyt o  WITH seq = value(reply->o_cons_cnt))
    PLAN (f)
     JOIN (o
     WHERE (reply->f_cons[f.seq].constraint_name=reply->o_cons[o.seq].constraint_name))
    DETAIL
     IF ((reply->f_cons[f.seq].constraint_type="R"))
      IF ((((reply->f_cons[f.seq].constraint_type != reply->o_cons[o.seq].constraint_type)) OR ((((
      reply->f_cons[f.seq].parent_table_name != reply->o_cons[o.seq].parent_table_name)) OR ((reply->
      f_cons[f.seq].columns != reply->o_cons[o.seq].columns))) )) )
       reply->f_cons[f.seq].diff_ind = 1
      ENDIF
     ELSE
      IF ((((reply->f_cons[f.seq].constraint_type != reply->o_cons[o.seq].constraint_type)) OR ((
      reply->f_cons[f.seq].columns != reply->o_cons[o.seq].columns))) )
       reply->f_cons[f.seq].diff_ind = 1
      ENDIF
     ENDIF
     reply->f_cons[f.seq].new_ind = 0, reply->o_cons[o.seq].new_ind = reply->f_cons[f.seq].new_ind,
     reply->o_cons[o.seq].diff_ind = reply->f_cons[f.seq].diff_ind
    WITH nocounter
   ;end select
  ENDIF
  IF ((reply->f_ind_cnt > 0)
   AND (reply->o_ind_cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt f  WITH seq = value(reply->f_ind_cnt)),
     (dummyt o  WITH seq = value(reply->o_ind_cnt))
    PLAN (f)
     JOIN (o
     WHERE (reply->f_ind[f.seq].index_name=reply->o_ind[o.seq].index_name))
    DETAIL
     IF ((((reply->f_ind[f.seq].unique_ind != reply->o_ind[o.seq].unique_ind)) OR ((reply->f_ind[f
     .seq].columns != reply->o_ind[o.seq].columns))) )
      reply->f_ind[f.seq].diff_ind = 1
     ENDIF
     reply->f_ind[f.seq].new_ind = 0, reply->o_ind[o.seq].new_ind = reply->f_ind[f.seq].new_ind,
     reply->o_ind[o.seq].diff_ind = reply->f_ind[f.seq].diff_ind
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (dm_debug=1)
  CALL echo("***")
  CALL echo("*** Checking for combine FK and Indexes on OCD")
  CALL echo("***")
 ENDIF
 SET cons_ind = 0
 SET indx_ind = 0
 FOR (ccnt = 1 TO reply->o_cons_cnt)
   IF ((reply->o_cons[ccnt].constraint_type="R"))
    SET cons_ind = 0
    SET indx_ind = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cmb_tables->tbl_cnt))
     PLAN (d
      WHERE (cmb_tables->tbl[d.seq].tbl_name=trim(reply->o_cons[ccnt].parent_table_name)))
     DETAIL
      cons_ind = cmb_tables->tbl[d.seq].cons_ind, indx_ind = cmb_tables->tbl[d.seq].indx_ind
     WITH nocounter
    ;end select
    IF (cons_ind=1)
     IF (dm_debug=1)
      CALL echo("***")
      CALL echo(build("*** Found combine FK:",reply->o_cons[ccnt].constraint_name))
      CALL echo("*** Force this to be unremovable from the OCD")
      CALL echo("***")
     ENDIF
     SET reply->o_cons[ccnt].cmb_ind = 1
     IF (dm_debug=1)
      CALL echo("***")
      CALL echo("*** Also force columns in this constraint to be unremovable from the OCD")
      CALL echo("***")
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt c  WITH seq = value(sch->o_cons[ccnt].col_cnt)),
       (dummyt t  WITH seq = value(reply->o_col_cnt))
      PLAN (c)
       JOIN (t
       WHERE (reply->o_cols[t.seq].column_name=sch->o_cons[ccnt].cols[c.seq].column_name))
      DETAIL
       reply->o_cols[t.seq].cmb_ind = 1
      WITH nocounter
     ;end select
     IF (indx_ind=1)
      SET trg_indx = 0
      SET trg_cols = 0
      FOR (icnt = 1 TO reply->o_ind_cnt)
        SET match_cols = 0
        SELECT INTO "nl:"
         FROM (dummyt i  WITH seq = value(sch->o_ind[icnt].col_cnt)),
          (dummyt c  WITH seq = value(sch->o_cons[ccnt].col_cnt))
         PLAN (c)
          JOIN (i
          WHERE (sch->o_cons[ccnt].cols[c.seq].col_pos=sch->o_ind[icnt].cols[i.seq].col_pos))
         ORDER BY sch->o_cons[ccnt].cols[c.seq].col_pos
         HEAD REPORT
          done = 0
         DETAIL
          IF (done=0)
           IF ((sch->o_cons[ccnt].cols[c.seq].column_name=sch->o_ind[icnt].cols[i.seq].column_name))
            match_cols = (match_cols+ 1)
           ELSE
            done = 1
           ENDIF
          ENDIF
         WITH nocounter
        ;end select
        IF (match_cols > trg_cols)
         SET trg_cols = match_cols
         SET trg_indx = icnt
        ENDIF
      ENDFOR
      IF (trg_indx > 0
       AND (trg_cols=sch->o_cons[ccnt].col_cnt))
       IF (dm_debug=1)
        CALL echo("***")
        CALL echo(build("*** Found combine index:",reply->o_ind[trg_indx].index_name))
        CALL echo("*** Force this to be unremovable from the OCD")
        CALL echo("***")
       ENDIF
       SET reply->o_ind[trg_indx].cmb_ind = 1
       IF (dm_debug=1)
        CALL echo("***")
        CALL echo("*** Also force columns in this index to be unremovable from the OCD")
        CALL echo("***")
       ENDIF
       SELECT INTO "nl:"
        FROM (dummyt c  WITH seq = value(sch->o_ind[trg_indx].col_cnt)),
         (dummyt t  WITH seq = value(reply->o_col_cnt))
        PLAN (c)
         JOIN (t
         WHERE (reply->o_cols[t.seq].column_name=sch->o_ind[trg_indx].cols[c.seq].column_name))
        DETAIL
         reply->o_cols[t.seq].cmb_ind = 1
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (dm_debug=1)
  CALL echo("***")
  CALL echo("*** Checking for combine FK and Indexes on Feature")
  CALL echo("***")
 ENDIF
 SET fc_name = fillstring(30," ")
 SET fc_cnt = 0
 SET fi_name = fillstring(30," ")
 SET fi_cnt = 0
 SET fcc_name = fillstring(30," ")
 SET fcc_cnt = 0
 SET oc_name = fillstring(30," ")
 SET oc_cnt = 0
 SET oi_name = fillstring(30," ")
 SET oi_cnt = 0
 SET fnd = 0
 FOR (ccnt = 1 TO reply->f_cons_cnt)
   IF ((reply->f_cons[ccnt].constraint_type="R"))
    SET cons_ind = 0
    SET indx_ind = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cmb_tables->tbl_cnt))
     PLAN (d
      WHERE (cmb_tables->tbl[d.seq].tbl_name=trim(reply->f_cons[ccnt].parent_table_name)))
     DETAIL
      cons_ind = cmb_tables->tbl[d.seq].cons_ind, indx_ind = cmb_tables->tbl[d.seq].indx_ind
     WITH nocounter
    ;end select
    IF (cons_ind=1)
     SET fc_cnt = ccnt
     SET fc_name = reply->f_cons[fc_cnt].constraint_name
     IF (dm_debug=1)
      CALL echo("***")
      CALL echo(build("*** Found combine FK:",fc_name))
      CALL echo("*** Check if constraint is already on OCD")
      CALL echo("***")
     ENDIF
     SET fnd = 0
     FOR (i = 1 TO reply->o_cons_cnt)
       IF ((reply->o_cons[i].constraint_type=reply->f_cons[fc_cnt].constraint_type)
        AND trim(reply->o_cons[i].columns)=trim(reply->f_cons[fc_cnt].columns))
        SET fnd = i
        SET i = reply->o_cons_cnt
       ENDIF
     ENDFOR
     IF (fnd=0)
      IF (dm_debug=1)
       CALL echo("***")
       CALL echo("*** Constraint not found on OCD")
       CALL echo("***")
      ENDIF
      SET oc_cnt = 0
      FOR (i = 1 TO reply->o_cons_cnt)
        IF ((reply->o_cons[i].constraint_name=reply->f_cons[fc_cnt].constraint_name))
         SET oc_cnt = i
         SET i = reply->o_cons_cnt
        ENDIF
      ENDFOR
      IF (oc_cnt=0)
       SET reply->o_cons_cnt = (reply->o_cons_cnt+ 1)
       SET oc_cnt = reply->o_cons_cnt
       SET stat = alterlist(reply->o_cons,oc_cnt)
       IF (dm_debug=1)
        CALL echo("***")
        CALL echo(build("*** Adding FK:",fc_name," from feature to OCD"))
        CALL echo("***")
       ENDIF
      ELSE
       IF (dm_debug=1)
        CALL echo("***")
        CALL echo(build("*** Replacing FK:",fc_name," on OCD from feature"))
        CALL echo("***")
       ENDIF
      ENDIF
      SET reply->o_cons[oc_cnt].constraint_name = reply->f_cons[fc_cnt].constraint_name
      SET reply->o_cons[oc_cnt].constraint_type = reply->f_cons[fc_cnt].constraint_type
      SET reply->o_cons[oc_cnt].parent_table_name = reply->f_cons[fc_cnt].parent_table_name
      SET reply->o_cons[oc_cnt].columns = reply->f_cons[fc_cnt].columns
      SET reply->o_cons[oc_cnt].cmb_ind = 1
      SET reply->o_cons[oc_cnt].new_ind = 1
      IF (dm_debug=1)
       CALL echo("***")
       CALL echo("*** Make sure columns in this constraint are also on OCD")
       CALL echo("***")
      ENDIF
      FOR (i = 1 TO sch->f_cons[fc_cnt].col_cnt)
        SET fnd = 0
        FOR (c = 1 TO reply->o_col_cnt)
          IF (trim(reply->o_cols[c].column_name)=trim(sch->f_cons[fc_cnt].cols[i].column_name))
           SET fnd = c
           SET c = reply->o_col_cnt
          ENDIF
        ENDFOR
        IF (fnd=0)
         SET fcc_cnt = 0
         FOR (c = 1 TO reply->f_col_cnt)
           IF (trim(reply->f_cols[c].column_name)=trim(sch->f_cons[fc_cnt].cols[i].column_name))
            SET fcc_cnt = c
            SET c = reply->f_col_cnt
           ENDIF
         ENDFOR
         IF (fcc_cnt > 0)
          IF (dm_debug=1)
           CALL echo("***")
           CALL echo(build("*** Add column:",reply->f_cols[fcc_cnt].column_name,
             " from feature to OCD"))
           CALL echo("***")
          ENDIF
          SET reply->o_col_cnt = (reply->o_col_cnt+ 1)
          SET fnd = reply->o_col_cnt
          SET stat = alterlist(reply->o_cols,fnd)
          SET reply->o_cols[fnd].column_name = reply->f_cols[fcc_cnt].column_name
          SET reply->o_cols[fnd].data_type = reply->f_cols[fcc_cnt].data_type
          SET reply->o_cols[fnd].data_length = reply->f_cols[fcc_cnt].data_length
          SET reply->o_cols[fnd].nullable = reply->f_cols[fcc_cnt].nullable
          SET reply->o_cols[fnd].data_default = reply->f_cols[fcc_cnt].data_default
          SET reply->o_cols[fnd].cmb_ind = 1
          SET reply->o_cols[fnd].new_ind = 1
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (indx_ind=1)
      SET trg_indx = 0
      SET trg_cols = 0
      IF (dm_debug=1)
       CALL echo("***")
       CALL echo("*** Looking for corresponding index...")
       CALL echo("***")
      ENDIF
      FOR (icnt = 1 TO reply->f_ind_cnt)
        SET match_cols = 0
        SELECT INTO "nl:"
         FROM (dummyt i  WITH seq = value(sch->f_ind[icnt].col_cnt)),
          (dummyt c  WITH seq = value(sch->f_cons[fc_cnt].col_cnt))
         PLAN (c)
          JOIN (i
          WHERE (sch->f_cons[fc_cnt].cols[c.seq].col_pos=sch->f_ind[icnt].cols[i.seq].col_pos))
         ORDER BY sch->f_cons[fc_cnt].cols[c.seq].col_pos
         HEAD REPORT
          done = 0
         DETAIL
          IF (done=0)
           IF ((sch->f_cons[fc_cnt].cols[c.seq].column_name=sch->f_ind[icnt].cols[i.seq].column_name)
           )
            match_cols = (match_cols+ 1)
           ELSE
            done = 1
           ENDIF
          ENDIF
         WITH nocounter
        ;end select
        IF (match_cols > trg_cols)
         SET trg_cols = match_cols
         SET trg_indx = icnt
        ENDIF
      ENDFOR
      IF (trg_indx > 0
       AND (trg_cols=sch->f_cons[fc_cnt].col_cnt))
       SET fi_cnt = trg_indx
       SET fi_name = reply->f_ind[fi_cnt].index_name
       IF (dm_debug=1)
        CALL echo("***")
        CALL echo(build("*** Found combine index:",fi_name))
        CALL echo("*** Check if this index is on OCD")
        CALL echo("***")
       ENDIF
       SET fnd = 0
       FOR (i = 1 TO reply->o_ind_cnt)
         IF (trim(reply->o_ind[i].columns)=trim(reply->f_ind[fi_cnt].columns))
          SET fnd = i
          SET i = reply->o_ind_cnt
         ENDIF
       ENDFOR
       IF (fnd=0)
        IF (dm_debug=1)
         CALL echo("***")
         CALL echo("*** Index not found on OCD")
         CALL echo("***")
        ENDIF
        SET oi_cnt = 0
        FOR (i = 1 TO reply->o_ind_cnt)
          IF ((reply->o_ind[i].index_name=reply->f_ind[fi_cnt].index_name))
           SET oi_cnt = i
           SET i = reply->o_ind_cnt
          ENDIF
        ENDFOR
        IF (oi_cnt=0)
         SET reply->o_ind_cnt = (reply->o_ind_cnt+ 1)
         SET oi_cnt = reply->o_ind_cnt
         SET stat = alterlist(reply->o_ind,oi_cnt)
         IF (dm_debug=1)
          CALL echo("***")
          CALL echo(build("*** Adding index:",fi_name," from feature to OCD"))
          CALL echo("***")
         ENDIF
        ELSE
         IF (dm_debug=1)
          CALL echo("***")
          CALL echo(build("*** Replacing index:",fi_name," on OCD from feature"))
          CALL echo("***")
         ENDIF
        ENDIF
        SET reply->o_ind[oi_cnt].index_name = reply->f_ind[fi_cnt].index_name
        SET reply->o_ind[oi_cnt].unique_ind = reply->f_ind[fi_cnt].unique_ind
        SET reply->o_ind[oi_cnt].columns = reply->f_ind[fi_cnt].columns
        SET reply->o_ind[oi_cnt].cmb_ind = 1
        SET reply->o_ind[oi_cnt].new_ind = 1
        IF (dm_debug=1)
         CALL echo("***")
         CALL echo("*** Make sure columns in this index are also on OCD")
         CALL echo("***")
        ENDIF
        FOR (i = 1 TO sch->f_ind[fi_cnt].col_cnt)
          SET fnd = 0
          FOR (c = 1 TO reply->o_col_cnt)
            IF ((reply->o_cols[c].column_name=sch->f_ind[fi_cnt].cols[i].column_name))
             SET fnd = c
             SET c = reply->o_col_cnt
            ENDIF
          ENDFOR
          IF (fnd=0)
           SET fcc_cnt = 0
           FOR (c = 1 TO reply->f_col_cnt)
             IF (trim(reply->f_cols[c].column_name)=trim(sch->f_ind[fi_cnt].cols[i].column_name))
              SET fcc_cnt = c
              SET c = reply->f_col_cnt
             ENDIF
           ENDFOR
           IF (fcc_cnt > 0)
            IF (dm_debug=1)
             CALL echo("***")
             CALL echo(build("*** Add column:",reply->f_cols[fcc_cnt].column_name),
              " from feature to OCD")
             CALL echo("***")
            ENDIF
            SET reply->o_col_cnt = (reply->o_col_cnt+ 1)
            SET fnd = reply->o_col_cnt
            SET stat = alterlist(reply->o_cols,fnd)
            SET reply->o_cols[fnd].column_name = reply->f_cols[fcc_cnt].column_name
            SET reply->o_cols[fnd].data_type = reply->f_cols[fcc_cnt].data_type
            SET reply->o_cols[fnd].data_length = reply->f_cols[fcc_cnt].data_length
            SET reply->o_cols[fnd].nullable = reply->f_cols[fcc_cnt].nullable
            SET reply->o_cols[fnd].data_default = reply->f_cols[fcc_cnt].data_default
            SET reply->o_cols[fnd].cmb_ind = 1
            SET reply->o_cols[fnd].new_ind = 1
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (dm_debug=1)
  CALL echo("***")
  CALL echo("*** Finally copy the o_ list into the b_ list")
  CALL echo("***")
 ENDIF
 IF ((reply->o_col_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reply->o_col_cnt))
   ORDER BY d.seq
   HEAD REPORT
    reply->b_col_cnt = reply->o_col_cnt, stat = alterlist(reply->b_cols,reply->b_col_cnt)
   DETAIL
    reply->b_cols[d.seq].column_name = reply->o_cols[d.seq].column_name, reply->b_cols[d.seq].
    data_type = reply->o_cols[d.seq].data_type, reply->b_cols[d.seq].data_length = reply->o_cols[d
    .seq].data_length,
    reply->b_cols[d.seq].nullable = reply->o_cols[d.seq].nullable, reply->b_cols[d.seq].data_default
     = reply->o_cols[d.seq].data_default, reply->b_cols[d.seq].new_ind = reply->o_cols[d.seq].new_ind,
    reply->b_cols[d.seq].diff_ind = reply->o_cols[d.seq].diff_ind, reply->b_cols[d.seq].cmb_ind =
    reply->o_cols[d.seq].cmb_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->o_cons_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reply->o_cons_cnt))
   ORDER BY d.seq
   HEAD REPORT
    reply->b_cons_cnt = reply->o_cons_cnt, stat = alterlist(reply->b_cons,reply->o_cons_cnt)
   DETAIL
    reply->b_cons[d.seq].constraint_name = reply->o_cons[d.seq].constraint_name, reply->b_cons[d.seq]
    .constraint_type = reply->o_cons[d.seq].constraint_type, reply->b_cons[d.seq].parent_table_name
     = reply->o_cons[d.seq].parent_table_name,
    reply->b_cons[d.seq].columns = reply->o_cons[d.seq].columns, reply->b_cons[d.seq].new_ind = reply
    ->o_cons[d.seq].new_ind, reply->b_cons[d.seq].diff_ind = reply->o_cons[d.seq].diff_ind,
    reply->b_cons[d.seq].cmb_ind = reply->o_cons[d.seq].cmb_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->o_ind_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(reply->o_ind_cnt))
   ORDER BY d.seq
   HEAD REPORT
    reply->b_ind_cnt = reply->o_ind_cnt, stat = alterlist(reply->b_ind,reply->b_ind_cnt)
   DETAIL
    reply->b_ind[d.seq].index_name = reply->o_ind[d.seq].index_name, reply->b_ind[d.seq].unique_ind
     = reply->o_ind[d.seq].unique_ind, reply->b_ind[d.seq].columns = reply->o_ind[d.seq].columns,
    reply->b_ind[d.seq].new_ind = reply->o_ind[d.seq].new_ind, reply->b_ind[d.seq].diff_ind = reply->
    o_ind[d.seq].diff_ind, reply->b_ind[d.seq].cmb_ind = reply->o_ind[d.seq].cmb_ind
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 IF (dm_debug=1)
  CALL echo("***")
  CALL echorecord(reply)
  CALL echo("***")
 ENDIF
#end_program
END GO
