CREATE PROGRAM dm_insert_feature_cs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD list(
   1 qual[*]
     2 env_name = vc
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT INTO "nl:"
  a.info_char
  FROM dm_info a
  WHERE a.info_name="ENV*"
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].env_name = a.info_char
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   INSERT  FROM dm_feature_code_sets_env c
    SET c.feature_number = request->feature_number, c.schema_dt_tm = cnvtdatetime(request->
      schema_date), c.code_set = request->code_set,
     c.code_set_env_status = null, c.environment = list->qual[cnt].env_name
   ;end insert
 ENDFOR
 COMMIT
 SET reply->status_data.status = "S"
END GO
