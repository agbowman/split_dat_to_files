CREATE PROGRAM dcp_chk_graph_name:dba
 SET modify = predeclare
 RECORD reply(
   1 dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM pred_graph pg
  PLAN (pg
   WHERE (pg.pred_graph_name=request->graph_name)
    AND (pg.owner_identifier=request->owner_id))
  DETAIL
   IF ((pg.pred_graph_id != request->graph_id))
    reply->dup_ind = 1
   ENDIF
 ;end select
 SET reply->status_data.status = "S"
END GO
