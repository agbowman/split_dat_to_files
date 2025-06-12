CREATE PROGRAM dm_drop_fkndx:dba
 DELETE  FROM dm_index_columns dic
  WHERE dic.schema_date=cnvtdatetime( $1)
   AND dic.index_name="FKNDX*"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_indexes di
  WHERE di.schema_date=cnvtdatetime( $1)
   AND di.index_name="FKNDX*"
  WITH nocounter
 ;end delete
 COMMIT
END GO
