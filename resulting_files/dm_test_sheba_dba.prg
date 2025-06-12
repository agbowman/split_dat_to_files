CREATE PROGRAM dm_test_sheba:dba
 SET ext = 0
 EXECUTE dm_temp_check
 FOR (cnts = 1 TO feature_table_list->table_count)
   SET feature_table_list->table_name[cnts].tname = "A"
 ENDFOR
END GO
