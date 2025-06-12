CREATE PROGRAM dm_purge_get_all_tok_tab:dba
 FREE SET reply
 RECORD reply(
   1 data[*]
     2 template_nbr = f8
     2 tokens[*]
       3 token_str = vc
       3 prompt_str = vc
       3 data_type_flag = i4
     2 tables[*]
       3 parent_table = vc
       3 child_table = vc
       3 parent_col1 = vc
       3 parent_col2 = vc
       3 parent_col3 = vc
       3 parent_col4 = vc
       3 parent_col5 = vc
       3 child_col1 = vc
       3 child_col2 = vc
       3 child_col3 = vc
       3 child_col4 = vc
       3 child_col5 = vc
       3 child_where = vc
       3 purge_type_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE v_where_str = vc
 SET reply->status_data.status = "F"
 SET v_tmpl_cnt = 0
 SELECT INTO "nl:"
  t.template_nbr
  FROM dm_purge_template t
  WHERE list(t.template_nbr,t.schema_dt_tm) IN (
  (SELECT
   t2.template_nbr, max(t2.schema_dt_tm)
   FROM dm_purge_template t2
   GROUP BY t2.template_nbr))
  DETAIL
   v_tmpl_cnt = (v_tmpl_cnt+ 1)
   IF (mod(v_tmpl_cnt,10)=1)
    stat = alterlist(reply->data,(v_tmpl_cnt+ 9))
   ENDIF
   reply->data[v_tmpl_cnt].template_nbr = t.template_nbr
  FOOT REPORT
   stat = alterlist(reply->data,v_tmpl_cnt)
  WITH nocounter
 ;end select
 FOR (tmpl_ndx = 1 TO v_tmpl_cnt)
   SET v_tok_cnt = 0
   SELECT INTO "nl:"
    t.token_str, t.prompt_str, t.data_type_flag
    FROM dm_purge_token t
    WHERE (t.template_nbr=reply->data[tmpl_ndx].template_nbr)
     AND (t.schema_dt_tm=
    (SELECT
     max(t2.schema_dt_tm)
     FROM dm_purge_token t2
     WHERE (t2.template_nbr=reply->data[tmpl_ndx].template_nbr)))
    DETAIL
     v_tok_cnt = (v_tok_cnt+ 1)
     IF (mod(v_tok_cnt,10)=1)
      stat = alterlist(reply->data[tmpl_ndx].tokens,(v_tok_cnt+ 9))
     ENDIF
     reply->data[tmpl_ndx].tokens[v_tok_cnt].token_str = t.token_str, reply->data[tmpl_ndx].tokens[
     v_tok_cnt].prompt_str = t.prompt_str, reply->data[tmpl_ndx].tokens[v_tok_cnt].data_type_flag = t
     .data_type_flag
    FOOT REPORT
     stat = alterlist(reply->data[tmpl_ndx].tokens,v_tok_cnt)
    WITH nocounter
   ;end select
   SET v_tab_cnt = 0
   SELECT INTO "nl:"
    t.parent_table, t.child_table, t.child_where,
    t.purge_type_flag, t.parent_col1, t.child_col1,
    t.parent_col2, t.child_col2, t.parent_col3,
    t.child_col3, t.parent_col4, t.child_col4,
    t.parent_col5, t.child_col5
    FROM dm_purge_table t
    WHERE (t.template_nbr=reply->data[tmpl_ndx].template_nbr)
     AND (t.schema_dt_tm=
    (SELECT
     max(t2.schema_dt_tm)
     FROM dm_purge_token t2
     WHERE (t2.template_nbr=reply->data[tmpl_ndx].template_nbr)))
    DETAIL
     v_tab_cnt = (v_tab_cnt+ 1)
     IF (mod(v_tab_cnt,10)=1)
      stat = alterlist(reply->data[tmpl_ndx].tables,(v_tab_cnt+ 9))
     ENDIF
     reply->data[tmpl_ndx].tables[v_tab_cnt].parent_table = t.parent_table, reply->data[tmpl_ndx].
     tables[v_tab_cnt].child_table = t.child_table, reply->data[tmpl_ndx].tables[v_tab_cnt].
     child_where = t.child_where,
     reply->data[tmpl_ndx].tables[v_tab_cnt].purge_type_flag = t.purge_type_flag, reply->data[
     tmpl_ndx].tables[v_tab_cnt].parent_col1 = t.parent_col1, reply->data[tmpl_ndx].tables[v_tab_cnt]
     .child_col1 = t.child_col1,
     reply->data[tmpl_ndx].tables[v_tab_cnt].parent_col2 = t.parent_col2, reply->data[tmpl_ndx].
     tables[v_tab_cnt].child_col2 = t.child_col2, reply->data[tmpl_ndx].tables[v_tab_cnt].parent_col3
      = t.parent_col3,
     reply->data[tmpl_ndx].tables[v_tab_cnt].child_col3 = t.child_col3, reply->data[tmpl_ndx].tables[
     v_tab_cnt].parent_col4 = t.parent_col4, reply->data[tmpl_ndx].tables[v_tab_cnt].child_col4 = t
     .child_col4,
     reply->data[tmpl_ndx].tables[v_tab_cnt].parent_col5 = t.parent_col5, reply->data[tmpl_ndx].
     tables[v_tab_cnt].child_col5 = t.child_col5
    FOOT REPORT
     stat = alterlist(reply->data[tmpl_ndx].tables,v_tab_cnt)
    WITH nocounter
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
END GO
