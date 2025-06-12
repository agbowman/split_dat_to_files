CREATE PROGRAM dm_del_orphan_rows:dba
 DELETE  FROM dm_env_del_tbl_lst
  WHERE 1=1
 ;end delete
 INSERT  FROM dm_env_del_tbl_lst
  (table_name, sequence, restrict_clause1)(SELECT
   table_name, rownum, concat("rowid='",row_id,"'")
   FROM dm_for_key_except)
 ;end insert
END GO
