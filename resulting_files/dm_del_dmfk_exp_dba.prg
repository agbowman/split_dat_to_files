CREATE PROGRAM dm_del_dmfk_exp:dba
 DELETE  FROM dm_for_key_except
  WHERE 1=1
 ;end delete
 COMMIT
END GO
