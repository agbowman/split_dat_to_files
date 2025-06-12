CREATE PROGRAM dm_env_mrg_cv_tbl_lst
 SET enviro_source =  $1
 SET db_link =  $2
 FREE SET request
 RECORD request(
   1 database_link = c12
   1 environment_source = c10
   1 beginning_code_set = f8
   1 ending_code_set = f8
   1 merge_mode_ind = i2
   1 merge_ind = i2
 )
 RECORD codeset_list(
   1 list[1]
     2 codeset = i4
     2 mode_flg = i2
 )
 SET d_count = 0
 SET count = 0
 SELECT INTO "nl:"
  *
  FROM dm_env_mrg_codeset_list d
  DETAIL
   d_count = (d_count+ 1), stat = alter(codeset_list->list,d_count), codeset_list->list[d_count].
   codeset = d.code_set,
   codeset_list->list[d_count].mode_flg = d.mode_flg
  WITH nocounter
 ;end select
 FOR (count = 1 TO d_count)
   SET request->database_link = db_link
   SET request->environment_source = enviro_source
   SET request->beginning_code_set = codeset_list->list[count].codeset
   SET request->ending_code_set = codeset_list->list[count].codeset
   SET request->merge_mode_ind = codeset_list->list[d_count].mode_flg
   SET request->merge_ind = 0
   FREE SET reply
   EXECUTE dm_env_mrg_code_values
 ENDFOR
END GO
