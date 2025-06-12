CREATE PROGRAM dm_ocd_feature_comp:dba
 FREE RECORD reply
 RECORD reply(
   1 count = i4
   1 qual[*]
     2 feature_number = i4
     2 list[*]
       3 table_name = vc
       3 schema_date = dq8
     2 kount = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,10)
 SET reply->status_data.status = "F"
 SET feature_count = request->qual_num
 SET rev_number = request->rev_number
 SET flag = 0
 SET rev_schema_date = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  a.schema_date
  FROM dm_schema_version a
  WHERE a.schema_version=rev_number
  DETAIL
   rev_schema_date = a.schema_date
  WITH nocounter
 ;end select
 SET reply->count = 0
 FOR (i = 1 TO feature_count)
   SET feature_number = request->qual[i].feature_number
   SET table_count = request->qual[i].list_num
   IF (table_count > 0)
    SET flag = 0
    FOR (j = 1 TO table_count)
      SET table_name = fillstring(40," ")
      SET table_name = trim(request->qual[i].tab_list[j].table_name)
      FREE SET r1
      RECORD r1(
        1 rdate = dq8
      )
      SET r1->rdate = 0
      SELECT INTO "nl:"
       a.schema_dt_tm, a.table_name
       FROM dm_feature_tables_env a
       WHERE a.feature_number=feature_number
        AND a.table_name=table_name
       ORDER BY a.schema_dt_tm
       DETAIL
        IF ((a.schema_dt_tm > r1->rdate))
         r1->rdate = a.schema_dt_tm
        ENDIF
       WITH nocounter
      ;end select
      IF ((rev_schema_date > r1->rdate))
       IF (flag=0)
        SET reply->count = (reply->count+ 1)
        SET stat = alterlist(reply->qual,reply->count)
        SET reply->qual[reply->count].feature_number = feature_number
       ENDIF
       SET flag = 1
       SET reply->qual[reply->count].kount = (reply->qual[reply->count].kount+ 1)
       SET stat = alterlist(reply->qual[reply->count].list,reply->qual[reply->count].kount)
       SET reply->qual[reply->count].list[reply->qual[reply->count].kount].table_name = table_name
       SET reply->qual[reply->count].list[reply->qual[reply->count].kount].schema_date = r1->rdate
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF ((reply->count=0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_program
END GO
