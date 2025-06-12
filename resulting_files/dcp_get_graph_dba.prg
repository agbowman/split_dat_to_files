CREATE PROGRAM dcp_get_graph:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pred_graph_inst_id = f8
     2 pred_graph_id = f8
     2 pred_graph_type_cd = f8
     2 graph_name = vc
     2 system_ind = i2
     2 items[*]
       3 pred_graph_item_id = f8
       3 event_set_cd = f8
       3 event_set_name = vc
       3 event_set_display = vc
       3 event_cd = f8
       3 prop[*]
         4 pred_graph_item_prop_id = f8
         4 prop_name = vc
         4 prop_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE qual_cnt = i4 WITH noconstant(cnvtint(size(request->qual,5)))
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE item_counter = i4 WITH noconstant(0)
 DECLARE prop_counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(qual_cnt)),
   pred_graph pg,
   pred_graph_item pgi,
   v500_event_set_code esc,
   pred_graph_item_prop pgip
  PLAN (d)
   JOIN (pg
   WHERE (pg.pred_graph_id=request->qual[d.seq].pred_graph_id)
    AND pg.active_ind=1)
   JOIN (pgi
   WHERE pgi.pred_graph_inst_id=outerjoin(pg.pred_graph_inst_id))
   JOIN (esc
   WHERE esc.event_set_name=outerjoin(pgi.event_set_name))
   JOIN (pgip
   WHERE pgip.pred_graph_item_id=outerjoin(pgi.pred_graph_item_id))
  ORDER BY cnvtlower(pg.pred_graph_name), pg.pred_graph_id, cnvtlower(pgi.event_set_name),
   pgi.pred_graph_item_id, pgip.pred_graph_item_prop_id
  HEAD pg.pred_graph_id
   item_counter = 0
   IF (pg.pred_graph_inst_id > 0)
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(reply->qual,(counter+ 9))
    ENDIF
    reply->qual[counter].pred_graph_id = pg.pred_graph_id, reply->qual[counter].pred_graph_inst_id =
    pg.pred_graph_inst_id, reply->qual[counter].graph_name = pg.pred_graph_name
    IF (pg.owner_identifier > 0)
     reply->qual[counter].system_ind = 0
    ELSE
     reply->qual[counter].system_ind = 1
    ENDIF
    reply->qual[counter].pred_graph_type_cd = pg.graph_type_cd
   ENDIF
  HEAD pgi.pred_graph_item_id
   prop_counter = 0
   IF (pgi.pred_graph_item_id > 0)
    item_counter = (item_counter+ 1)
    IF (mod(item_counter,10)=1)
     stat = alterlist(reply->qual[counter].items,(item_counter+ 9))
    ENDIF
    reply->qual[counter].items[item_counter].pred_graph_item_id = pgi.pred_graph_item_id, reply->
    qual[counter].items[item_counter].event_set_name = pgi.event_set_name, reply->qual[counter].
    items[item_counter].event_set_display = esc.event_set_cd_disp,
    reply->qual[counter].items[item_counter].event_cd = pgi.event_cd, reply->qual[counter].items[
    item_counter].event_set_cd = esc.event_set_cd
   ENDIF
  HEAD pgip.pred_graph_item_prop_id
   IF (pgip.pred_graph_item_prop_id > 0)
    prop_counter = (prop_counter+ 1)
    IF (mod(prop_counter,10)=1)
     stat = alterlist(reply->qual[counter].items[item_counter].prop,(prop_counter+ 9))
    ENDIF
    reply->qual[counter].items[item_counter].prop[prop_counter].pred_graph_item_prop_id = pgip
    .pred_graph_item_prop_id, reply->qual[counter].items[item_counter].prop[prop_counter].prop_name
     = pgip.prop_name, reply->qual[counter].items[item_counter].prop[prop_counter].prop_value = pgip
    .prop_value
   ENDIF
  FOOT  pgi.pred_graph_item_id
   IF (pgi.pred_graph_item_id > 0)
    stat = alterlist(reply->qual[counter].items[item_counter].prop,prop_counter)
   ENDIF
  FOOT  pg.pred_graph_id
   IF (pg.pred_graph_id)
    stat = alterlist(reply->qual[counter].items,item_counter)
   ENDIF
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
