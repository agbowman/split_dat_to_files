CREATE PROGRAM dm_columns_doc_csv:dba
 SET str_data = fillstring(320," ")
 SELECT INTO "REV6_DOC.CSV"
  str_data = concat(trim(td.data_model_section),",",trim(c.table_name),",",trim(cd.column_name),
   ",",trim(substring(1,80,cd.description)),",",cnvtstring(cd.code_set,5,0,r),",",
   trim(c.data_type),",",trim(c.nullable),",",trim(substring(1,40,c.data_default)),
   ",",trim(cd.sequence_name))
  FROM dm_columns_doc cd,
   dm_columns c,
   dm_data_model_section dms,
   dm_tables_doc td,
   dm_tables t
  WHERE t.schema_date=cnvtdatetime("01-sep-1997")
   AND td.table_name=t.table_name
   AND dms.data_model_section=td.data_model_section
   AND c.schema_date=cnvtdatetime("01-sep-1997")
   AND c.table_name=td.table_name
   AND cd.table_name=c.table_name
   AND cd.column_name=c.column_name
  ORDER BY td.data_model_section, cd.table_name, cd.column_name
  HEAD REPORT
   col 0,
   "data_model_section, table_name, column_name, description, code_set, data_type, nullable, data_default, sequenc_name",
   row + 1
  DETAIL
   col 0, str_data, row + 1
  WITH nocounter, maxcol = 320, maxrow = 1,
   noformfeed, noformat, noheading
 ;end select
END GO
