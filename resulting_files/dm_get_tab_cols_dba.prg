CREATE PROGRAM dm_get_tab_cols:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 column_name = vc
   1 count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET tname = fillstring(40," ")
 SET reply->status_data.status = "F"
 SET fnumber = request->feature_number
 SET tname = request->table_name
 SET reply->count = 0
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "nl:"
  a.schema_dt_tm
  FROM dm_feature_tables_env a
  WHERE a.feature_number=fnumber
   AND a.table_name=tname
  DETAIL
   IF ((a.schema_dt_tm > r1->rdate))
    r1->rdate = a.schema_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.column_name
  FROM dm_adm_columns d
  WHERE d.table_name=tname
   AND datetimediff(d.schema_date,cnvtdatetime(r1->rdate))=0
  ORDER BY d.column_name
  DETAIL
   reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
   count].column_name = d.column_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
