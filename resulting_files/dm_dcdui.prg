CREATE PROGRAM dm_dcdui
 SELECT
  *
  FROM dm_columns_doc
  WHERE table_name=cnvtupper( $1)
   AND unique_ident_ind=1
  WITH nocounter
 ;end select
END GO
