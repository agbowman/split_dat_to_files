CREATE PROGRAM dm_get_soft_cons:dba
 RECORD reply(
   1 qual[*]
     2 child_column = c30
     2 child_table = c30
     2 child_where = vc
     2 parent_column = c30
     2 parent_table = c30
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
 SELECT INTO "NL:"
  a.child_column, a.child_table, a.child_where,
  a.parent_column, a.parent_table
  FROM dm_soft_constraints a
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].child_column = a.child_column,
   reply->qual[cnt].child_table = a.child_table, reply->qual[cnt].child_where = a.child_where, reply
   ->qual[cnt].parent_column = a.parent_column,
   reply->qual[cnt].parent_table = a.parent_table
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
