CREATE PROGRAM dm_oe_parfile:dba
 SET func_id =  $1
 SET file_name = concat( $2,".par")
 SET sdate = cnvtdatetime( $3)
 SET cnt = 0
 SELECT INTO value(file_name)
  a.table_name
  FROM dm_tables_doc a,
   dm_product_functions b,
   dm_function_dependencies c,
   dm_function_dm_section_r d,
   dm_tables e
  WHERE b.function_id=func_id
   AND b.function_id=c.function_id
   AND ((c.required_function_id=d.function_id) OR (c.function_id=d.function_id))
   AND d.data_model_section=a.data_model_section
   AND a.table_name=e.table_name
   AND e.schema_date=cnvtdatetime(sdate)
  ORDER BY a.table_name
  HEAD REPORT
   col 0, " TABLES = (", row + 1
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 1)
    col 0, ","
   ENDIF
   col 2, a.table_name, row + 1
  FOOT REPORT
   col 0, ")"
  WITH nocounter, formfeed = none, maxrow = 1
 ;end select
END GO
