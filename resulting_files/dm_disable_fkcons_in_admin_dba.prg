CREATE PROGRAM dm_disable_fkcons_in_admin:dba
 UPDATE  FROM dm_constraints dc
  SET dc.status_ind = 0
  WHERE dc.schema_date=cnvtdatetime( $1)
   AND dc.status_ind=1
   AND dc.constraint_type="R"
  WITH nocounter
 ;end update
 COMMIT
END GO
