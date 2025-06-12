CREATE PROGRAM dm_cert_table_list:dba
 DELETE  FROM dm_table_list
  WHERE 1=1
 ;end delete
 COMMIT
 INSERT  FROM dm_table_list
  (table_name, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task)(SELECT
   t.table_name, x1 = 0, x2 = cnvtdatetime(curdate,curtime3),
   x3 = 0, x4 = 0, x5 = 0
   FROM dm_tables_doc t
   WHERE t.schema_refresh_request_dt_tm=cnvtdatetime( $1))
  WITH nocounter
 ;end insert
 COMMIT
END GO
