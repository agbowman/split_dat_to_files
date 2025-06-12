CREATE PROGRAM dm_get_table_owner:dba
 SELECT
  td.table_name, data_model_section = substring(1,30,td.data_model_section), dms.owner_name
  FROM dm_data_model_section dms,
   dm_tables_doc td
  WHERE td.table_name=patstring(cnvtupper( $1))
   AND dms.data_model_section=td.data_model_section
  ORDER BY td.table_name
  WITH nocounter
 ;end select
END GO
