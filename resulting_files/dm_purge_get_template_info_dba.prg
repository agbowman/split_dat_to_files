CREATE PROGRAM dm_purge_get_template_info:dba
 FREE SET reply
 RECORD reply(
   1 tokens[*]
     2 token_str = vc
     2 prompt_str = vc
     2 data_type_flag = i4
   1 tables[*]
     2 parent_table = vc
     2 child_table = vc
     2 child_where = vc
     2 purge_type_flag = i4
     2 parent_col1 = vc
     2 child_col1 = vc
     2 parent_col2 = vc
     2 child_col2 = vc
     2 parent_col3 = vc
     2 child_col3 = vc
     2 parent_col4 = vc
     2 child_col4 = vc
     2 parent_col5 = vc
     2 child_col5 = vc
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
 SET v_tok_cnt = 0
 SELECT INTO "nl:"
  t.token_str, t.prompt_str, t.data_type_flag
  FROM dm_purge_token t
  WHERE (t.template_nbr=request->template_nbr)
   AND (t.schema_dt_tm=
  (SELECT
   max(t2.schema_dt_tm)
   FROM dm_purge_token t2
   WHERE (t2.template_nbr=request->template_nbr)))
  DETAIL
   v_tok_cnt = (v_tok_cnt+ 1)
   IF (mod(v_tok_cnt,10)=1)
    stat = alterlist(reply->tokens,(v_tok_cnt+ 9))
   ENDIF
   reply->tokens[v_tok_cnt].token_str = t.token_str, reply->tokens[v_tok_cnt].prompt_str = t
   .prompt_str, reply->tokens[v_tok_cnt].data_type_flag = t.data_type_flag
  FOOT REPORT
   stat = alterlist(reply->tokens,v_tok_cnt)
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
  WHERE (t.template_nbr=request->template_nbr)
   AND (t.schema_dt_tm=
  (SELECT
   max(t2.schema_dt_tm)
   FROM dm_purge_table t2
   WHERE (t2.template_nbr=request->template_nbr)))
  DETAIL
   v_tab_cnt = (v_tab_cnt+ 1)
   IF (mod(v_tab_cnt,10)=1)
    stat = alterlist(reply->tables,(v_tab_cnt+ 9))
   ENDIF
   reply->tables[v_tab_cnt].parent_table = t.parent_table, reply->tables[v_tab_cnt].child_table = t
   .child_table, reply->tables[v_tab_cnt].child_where = t.child_where,
   reply->tables[v_tab_cnt].purge_type_flag = t.purge_type_flag, reply->tables[v_tab_cnt].parent_col1
    = t.parent_col1, reply->tables[v_tab_cnt].child_col1 = t.child_col1,
   reply->tables[v_tab_cnt].parent_col2 = t.parent_col2, reply->tables[v_tab_cnt].child_col2 = t
   .child_col2, reply->tables[v_tab_cnt].parent_col3 = t.parent_col3,
   reply->tables[v_tab_cnt].child_col3 = t.child_col3, reply->tables[v_tab_cnt].parent_col4 = t
   .parent_col4, reply->tables[v_tab_cnt].child_col4 = t.child_col4,
   reply->tables[v_tab_cnt].parent_col5 = t.parent_col5, reply->tables[v_tab_cnt].child_col5 = t
   .child_col5
  FOOT REPORT
   stat = alterlist(reply->tables,v_tab_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
