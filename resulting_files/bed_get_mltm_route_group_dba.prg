CREATE PROGRAM bed_get_mltm_route_group:dba
 FREE SET reply
 RECORD reply(
   1 route_grouper[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 routes[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_drc(
   1 dlist[*]
     2 route = f8
     2 drc_premise_id = f8
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SET sub_cnt = 0
 SET sub_list_count = 0
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m
  ORDER BY m.route_id
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(temp_drc->dlist,50)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 50)
    stat = alterlist(temp_drc->dlist,(cnt+ 50)), list_count = 1
   ENDIF
   temp_drc->dlist[cnt].route = m.route_id
  FOOT REPORT
   stat = alterlist(temp_drc->dlist,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    dcp_entity_reltn der,
    code_value cv
   PLAN (d)
    JOIN (der
    WHERE (der.entity1_id=temp_drc->dlist[d.seq].route)
     AND der.entity_reltn_mean="DRC/ROUTE")
    JOIN (cv
    WHERE cv.code_value=der.entity2_id
     AND cv.active_ind=1)
   HEAD REPORT
    sub_cnt = 0, list_count = 0, stat = alterlist(reply->route_grouper,50)
   DETAIL
    sub_cnt = (sub_cnt+ 1), list_count = (list_count+ 1)
    IF (list_count > 50)
     stat = alterlist(reply->route_grouper,(sub_cnt+ 50)), list_count = 1
    ENDIF
    reply->route_grouper[sub_cnt].code_value = cv.code_value, reply->route_grouper[sub_cnt].
    description = cv.description, reply->route_grouper[sub_cnt].display = cv.display
   FOOT REPORT
    stat = alterlist(reply->route_grouper,sub_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(temp_drc->dlist,sub_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = sub_cnt),
    drc_premise_list dpl
   PLAN (d)
    JOIN (dpl
    WHERE (dpl.parent_entity_id=reply->route_grouper[d.seq].code_value)
     AND dpl.active_ind=1)
   HEAD dpl.parent_entity_id
    temp_drc->dlist[d.seq].drc_premise_id = dpl.drc_premise_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = sub_cnt),
    drc_premise_list dpl,
    code_value cv
   PLAN (d)
    JOIN (dpl
    WHERE (dpl.drc_premise_id=temp_drc->dlist[d.seq].drc_premise_id)
     AND dpl.drc_premise_id > 0
     AND (dpl.parent_entity_id != reply->route_grouper[d.seq].code_value)
     AND dpl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dpl.parent_entity_id)
   HEAD d.seq
    list_count = 0, sub_list_count = 0, stat = alterlist(reply->route_grouper[d.seq].routes,10)
   DETAIL
    list_count = (list_count+ 1), sub_list_count = (sub_list_count+ 1)
    IF (sub_list_count > 10)
     stat = alterlist(reply->route_grouper[d.seq].routes,(list_count+ 10)), sub_list_count = 1
    ENDIF
    reply->route_grouper[d.seq].routes[list_count].code_value = dpl.parent_entity_id, reply->
    route_grouper[d.seq].routes[list_count].description = cv.description, reply->route_grouper[d.seq]
    .routes[list_count].display = cv.display,
    reply->route_grouper[d.seq].routes[list_count].active_ind = cv.active_ind
   FOOT  d.seq
    stat = alterlist(reply->route_grouper[d.seq].routes,list_count)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
