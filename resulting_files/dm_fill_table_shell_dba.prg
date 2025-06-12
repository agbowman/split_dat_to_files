CREATE PROGRAM dm_fill_table_shell:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dm_string = fillstring(255," ")
 SET dm_string = concat("DM_FILL_TABLE_SP ","'")
 SET dm_string = build(dm_string,request->table_name)
 SET dm_string = build(dm_string,"'")
 SET dm_string = build(dm_string,", ")
 SET dm_string = build(dm_string,"'")
 SET dm_string = build(dm_string,request->schema_date)
 SET dm_string = build(dm_string,"'")
 SET dm_string = build(dm_string," GO")
 CALL parser(dm_string,1)
 SELECT INTO "nl:"
  a.*
  FROM dm_adm_tables a
  WHERE a.schema_date=cnvtdatetimeutc(request->alternate_format,0)
   AND a.table_name=trim(request->table_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
