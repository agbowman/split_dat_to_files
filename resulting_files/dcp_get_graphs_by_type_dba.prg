CREATE PROGRAM dcp_get_graphs_by_type:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pred_graph_id = f8
     2 pred_graph_inst_id = f8
     2 pred_graph_type_cd = f8
     2 name = vc
     2 system_ind = i2
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
 IF ((request->pred_graph_type_cd > 0))
  SELECT INTO "nl:"
   FROM pred_graph pg
   PLAN (pg
    WHERE (pg.graph_type_cd=request->pred_graph_type_cd)
     AND pg.active_ind=1
     AND pg.owner_identifier=0)
   ORDER BY pg.graph_type_cd, cnvtlower(pg.pred_graph_name), pg.pred_graph_id
   HEAD pg.pred_graph_id
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(reply->qual,(counter+ 9))
    ENDIF
    reply->qual[counter].pred_graph_id = pg.pred_graph_id, reply->qual[counter].pred_graph_inst_id =
    pg.pred_graph_inst_id, reply->qual[counter].name = pg.pred_graph_name,
    reply->qual[counter].system_ind = 1, reply->qual[counter].pred_graph_type_cd = pg.graph_type_cd
   FOOT REPORT
    stat = alterlist(reply->qual,counter)
   WITH nocounter
  ;end select
 ELSEIF ((request->pred_graph_type_cd=0))
  SELECT INTO "nl:"
   FROM pred_graph pg
   WHERE pg.active_ind=1
    AND pg.owner_identifier=0
   ORDER BY pg.graph_type_cd, cnvtlower(pg.pred_graph_name), pg.pred_graph_id
   HEAD pg.pred_graph_id
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(reply->qual,(counter+ 9))
    ENDIF
    reply->qual[counter].pred_graph_id = pg.pred_graph_id, reply->qual[counter].pred_graph_inst_id =
    pg.pred_graph_inst_id, reply->qual[counter].name = pg.pred_graph_name,
    reply->qual[counter].system_ind = 1, reply->qual[counter].pred_graph_type_cd = pg.graph_type_cd
   FOOT REPORT
    stat = alterlist(reply->qual,counter)
   WITH nocounter
  ;end select
 ENDIF
 IF (counter=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
