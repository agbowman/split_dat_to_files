CREATE PROGRAM dm_dcd
 SELECT
  *
  FROM dm_columns_doc
  WHERE table_name=cnvtupper( $1)
  WITH nocounter
 ;end select
END GO
