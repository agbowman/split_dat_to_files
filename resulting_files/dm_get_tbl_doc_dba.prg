CREATE PROGRAM dm_get_tbl_doc:dba
 RECORD reply(
   1 qual[*]
     2 table_name = c30
     2 reference_ind = i2
     2 human_reqd_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.*
  FROM dm_tables_doc a,
   user_tables b
  WHERE a.table_name=b.table_name
   AND ((a.reference_ind=1) OR (a.table_name IN ("ACCESSION", "PERSON", "PRSNL", "LONG_TEXT",
  "LONG_BLOB",
  "ADDRESS", "PHONE")))
  ORDER BY a.table_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].table_name = a.table_name,
   reply->qual[cnt].reference_ind = a.reference_ind, reply->qual[cnt].human_reqd_ind = a
   .human_reqd_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
