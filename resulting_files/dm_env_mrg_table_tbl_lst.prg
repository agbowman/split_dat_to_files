CREATE PROGRAM dm_env_mrg_table_tbl_lst
 SET enviro_source =  $1
 SET db_link =  $2
 SET commit_ind =  $3
 FREE SET request
 RECORD request(
   1 merge_table = c30
   1 restrict_clause = c255
   1 db_link = c20
   1 enviro_source = c20
   1 commit_ind = i2
   1 mode_flg = i2
   1 dup_ck_ind = i2
 )
 RECORD table_list(
   1 list[1]
     2 merge_table = c30
     2 restrict_clause = c255
     2 mode_flg = i2
     2 dup_ck_ind = i2
 )
 SET d_count = 0
 SET count = 0
 SELECT INTO "nl:"
  *
  FROM dm_env_mrg_table_list d
  WHERE process_flg=2
  ORDER BY d.mrg_order
  DETAIL
   d_count = (d_count+ 1), stat = alter(table_list->list,d_count), table_list->list[d_count].
   merge_table = d.table_name,
   table_list->list[d_count].restrict_clause = d.restrict_clause, table_list->list[d_count].mode_flg
    = d.mode_flg, table_list->list[d_count].dup_ck_ind = d.dup_check_ind
  WITH nocounter
 ;end select
 FOR (count = 1 TO d_count)
   SET request->db_link = db_link
   SET request->enviro_source = enviro_source
   SET request->merge_table = table_list->list[count].merge_table
   SET request->restrict_clause = table_list->list[count].restrict_clause
   SET request->commit_ind = commit_ind
   SET request->mode_flg = table_list->list[count].mode_flg
   SET request->dup_ck_ind = table_list->list[count].dup_ck_ind
 ENDFOR
END GO
