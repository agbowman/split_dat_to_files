CREATE PROGRAM dm_get_tables:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 table_name = vc
   1 count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fnumber = request->feature_number
 SET reply->count = 0
 SELECT DISTINCT INTO "nl:"
  d.table_name
  FROM dm_feature_tables_env d
  WHERE d.feature_number=fnumber
  ORDER BY d.table_name
  DETAIL
   reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
   count].table_name = d.table_name
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  d.proj_name
  FROM dm_project_status_env d
  WHERE d.feature=fnumber
   AND d.proj_type="SCHEMA"
  ORDER BY d.proj_name
  DETAIL
   dmx = 0, dmflag = 0
   FOR (dmx = 1 TO reply->count)
     IF ((reply->qual[dmx].table_name=d.proj_name))
      dmflag = 1, dmx = reply->count
     ENDIF
   ENDFOR
   IF (dmflag=0)
    reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
    count].table_name = d.proj_name
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
