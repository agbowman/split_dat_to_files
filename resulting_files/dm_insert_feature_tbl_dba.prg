CREATE PROGRAM dm_insert_feature_tbl:dba
 RECORD list(
   1 qual[*]
     2 env_name = vc
   1 count = i4
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET list->count = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.info_char
  FROM dm_info a
  WHERE a.info_name="ENV*"
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->qual,list->count), list->qual[list->count].
   env_name = a.info_char
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   INSERT  FROM dm_feature_tables_env c
    SET c.feature_number = request->feature_number, c.schema_dt_tm = cnvtdatetime(request->
      schema_date), c.table_name = request->table_name,
     c.table_env_status = null, c.environment = list->qual[cnt].env_name
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO
