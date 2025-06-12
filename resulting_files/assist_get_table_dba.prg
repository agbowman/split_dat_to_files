CREATE PROGRAM assist_get_table:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 table_qual = i4
    1 table_name[10]
      2 table_name = c30
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "ALL_TABLES"
 SET kount = 0
 SELECT DISTINCT INTO "NL:"
  a.table_name
  FROM all_tables a
  WHERE (a.owner=request->owner)
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1
    AND kount != 1)
    stat = alter(reply->table_name,(kount+ 10))
   ENDIF
   reply->table_name[kount].table_name = a.table_name
  WITH nocounter
 ;end select
 SET reply->table_qual = kount
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 SET stat = alter(reply->table_name,kount)
 GO TO end_program
#end_program
END GO
