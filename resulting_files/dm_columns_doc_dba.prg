CREATE PROGRAM dm_columns_doc:dba
 SELECT
  *
  FROM dm_columns_doc
  WHERE (table_name= $1)
 ;end select
END GO
