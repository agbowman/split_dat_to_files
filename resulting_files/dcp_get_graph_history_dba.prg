CREATE PROGRAM dcp_get_graph_history:dba
 SET modify = predeclare
 RECORD reply(
   1 pred_graph_id = f8
   1 qual[*]
     2 pred_graph_inst_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 graph_name = vc
     2 items[*]
       3 pred_graph_item_id = f8
       3 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE item_counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM pred_graph pg,
   pred_graph_item pgi
  PLAN (pg
   WHERE (pg.pred_graph_id=request->pred_graph_id))
   JOIN (pgi
   WHERE pgi.pred_graph_inst_id=outerjoin(pg.pred_graph_inst_id))
  ORDER BY pg.end_effective_dt_tm DESC, pg.pred_graph_inst_id, cnvtlower(pgi.event_set_name),
   pgi.pred_graph_item_id
  HEAD REPORT
   counter = 0, reply->pred_graph_id = pg.pred_graph_id
  HEAD pg.pred_graph_inst_id
   item_counter = 0, counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].pred_graph_inst_id = pg.pred_graph_inst_id, reply->qual[counter].
   beg_effective_dt_tm = cnvtdatetime(pg.beg_effective_dt_tm), reply->qual[counter].
   end_effective_dt_tm = cnvtdatetime(pg.end_effective_dt_tm),
   reply->qual[counter].graph_name = pg.pred_graph_name
  HEAD pgi.pred_graph_item_id
   IF (pgi.pred_graph_item_id > 0)
    item_counter = (item_counter+ 1)
    IF (mod(item_counter,10)=1)
     stat = alterlist(reply->qual[counter].items,(item_counter+ 9))
    ENDIF
    reply->qual[counter].items[item_counter].pred_graph_item_id = pgi.pred_graph_item_id, reply->
    qual[counter].items[item_counter].event_set_name = pgi.event_set_name
   ENDIF
  FOOT  pg.pred_graph_inst_id
   stat = alterlist(reply->qual[counter].items,item_counter)
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (counter=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
