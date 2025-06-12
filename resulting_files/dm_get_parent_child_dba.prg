CREATE PROGRAM dm_get_parent_child:dba
 RECORD reply(
   1 qual[*]
     2 entity_name = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 IF ((request->pc_ind=0))
  SELECT DISTINCT INTO "nl:"
   d.parent_table
   FROM dm_parent_child d
   WHERE (d.child_table=request->entity_name)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].entity_name = d
    .parent_table
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   d.child_table
   FROM dm_parent_child d
   WHERE (d.parent_table=request->entity_name)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].entity_name = d
    .child_table
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "N"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
