CREATE PROGRAM dm_dcdflg
 UPDATE  FROM dm_columns_doc
  SET exception_flg =  $3
  WHERE table_name=cnvtupper( $1)
   AND column_name=cnvtupper( $2)
 ;end update
END GO
