CREATE PROGRAM dm_make_csv_softcons:dba
 SET file1_str = "ccluserdir:dmsoftcons.csv"
 SET logical file1 "ccluserdir:dmsoftcons.csv"
 SELECT INTO file1
  d.child_column, d.child_table, d.child_where,
  d.parent_column, d.parent_table, d.code_set,
  d.exclude_ind, d.reference_ind
  FROM dm_soft_constraints d
  ORDER BY d.child_column, d.child_table, d.parent_column,
   d.parent_table
  WITH format = pcformat
 ;end select
 IF (findfile(file1_str))
  CALL echo(concat("File created: '",file1_str,"'"))
 ENDIF
END GO
