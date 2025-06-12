CREATE PROGRAM dm_make_csv_tbldoc:dba
 SET file1_str = "ccluserdir:dmrtbldoc.csv"
 SET logical file1 "ccluserdir:dmrtbldoc.csv"
 SELECT INTO file1
  d.table_name, d.reference_ind, d.human_reqd_ind
  FROM dm_tables_doc d
  WHERE d.reference_ind=1
  ORDER BY d.table_name
  WITH format = pcformat, check
 ;end select
 IF (findfile(file1_str))
  CALL echo(concat("File created: '",file1_str,"'"))
 ENDIF
END GO
