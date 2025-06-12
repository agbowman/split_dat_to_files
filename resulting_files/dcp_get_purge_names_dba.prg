CREATE PROGRAM dcp_get_purge_names:dba
 RECORD reply(
   1 qual[*]
     2 desc = vc
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET x = 0
 SET stat = 0
 SELECT INTO "nl:"
  pc.tl_purge_description, pc.tl_purge_id
  FROM tl_purge_criteria pc
  WHERE pc.active_ind=1
  ORDER BY pc.tl_purge_description
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->qual,5))
    stat = alterlist(reply->qual,(x+ 10))
   ENDIF
   reply->qual[x].desc = pc.tl_purge_description, reply->qual[x].id = pc.tl_purge_id,
   CALL echo(build("id found->",pc.tl_purge_id)),
   CALL echo("")
  FOOT REPORT
   stat = alterlist(reply->qual,x),
   CALL echo(build("size of reply=",x))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "tl_purge_criteria table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_add_purge_criteria"
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
