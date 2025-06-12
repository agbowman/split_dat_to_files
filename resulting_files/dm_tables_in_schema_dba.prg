CREATE PROGRAM dm_tables_in_schema:dba
 SET schema_ver = 0
 SET schema_ver =  $1
 SET schema_date = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  d.schema_date
  FROM dm_schema_version d
  WHERE d.schema_version=schema_ver
  DETAIL
   schema_date = d.schema_date
  WITH nocounter
 ;end select
 SELECT INTO "dm_tables_in_schema"
  dtd.data_model_section, dtd.table_name, dms.owner_name
  FROM dm_tables_doc dtd,
   dm_tables dt,
   dm_data_model_section dms
  WHERE dt.schema_date=cnvtdatetime(schema_date)
   AND dtd.table_name=dt.table_name
   AND dms.data_model_section=dtd.data_model_section
  ORDER BY dtd.data_model_section, dt.table_name
  WITH nocounter, separator = ","
 ;end select
END GO
