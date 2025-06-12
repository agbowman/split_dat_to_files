CREATE PROGRAM dcp_get_favorites:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pred_graph_inst_id = f8
     2 pred_graph_id = f8
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
 SELECT INTO "nl:"
  FROM pred_graph_reltn pgr,
   pred_graph pg
  PLAN (pgr
   WHERE (pgr.parent_entity_id=reqinfo->updt_id)
    AND pgr.parent_entity_name="PRSNL"
    AND pgr.active_ind=1)
   JOIN (pg
   WHERE pg.pred_graph_inst_id=pgr.pred_graph_inst_id)
  ORDER BY cnvtlower(pg.pred_graph_name), pg.pred_graph_inst_id
  HEAD REPORT
   counter = 0
  HEAD pg.pred_graph_inst_id
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].pred_graph_id = pg.pred_graph_id, reply->qual[counter].pred_graph_inst_id =
   pg.pred_graph_inst_id, reply->qual[counter].name = pg.pred_graph_name
   IF (pg.owner_identifier > 0)
    reply->qual[counter].system_ind = 0
   ELSE
    reply->qual[counter].system_ind = 1
   ENDIF
   reply->qual[counter].pred_graph_type_cd = pg.graph_type_cd
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
