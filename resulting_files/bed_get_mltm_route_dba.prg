CREATE PROGRAM bed_get_mltm_route:dba
 FREE SET reply
 RECORD reply(
   1 multum_routes[*]
     2 display = vc
     2 route_id = f8
     2 ignore_ind = i2
     2 route_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 no_content_ind = i2
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SET reply->no_content_ind = 0
 SET mltm_data_populated = 0
 SELECT INTO "nl:"
  FROM mltm_drc_route m
  WHERE m.route_code > 0
  DETAIL
   mltm_data_populated = 1
  WITH nocounter, maxqual = 1
 ;end select
 IF (mltm_data_populated=0)
  SET reply->no_content_ind = 1
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m
  ORDER BY m.route_id
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->multum_routes,100)
  HEAD m.route_id
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->multum_routes,(cnt+ 100)), list_count = 1
   ENDIF
   reply->multum_routes[cnt].display = m.route_disp, reply->multum_routes[cnt].route_id = m.route_id,
   reply->multum_routes[cnt].ignore_ind = 0
  FOOT REPORT
   stat = alterlist(reply->multum_routes,cnt)
  WITH nocounter
 ;end select
 SET cnt = size(reply->multum_routes,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    dcp_entity_reltn der,
    code_value cv
   PLAN (d)
    JOIN (der
    WHERE (der.entity1_id=reply->multum_routes[d.seq].route_id)
     AND der.entity1_name="MLTM_DRC_PREMISE"
     AND der.entity2_name="CODE_VALUE")
    JOIN (cv
    WHERE cv.code_value=der.entity2_id)
   DETAIL
    reply->multum_routes[d.seq].route_code_value = der.entity2_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    br_name_value b
   PLAN (d)
    JOIN (b
    WHERE b.br_value=cnvtstring(reply->multum_routes[d.seq].route_id)
     AND b.br_nv_key1="MLTM_IGN_ROUTE"
     AND b.br_name="MLTM_DRC_PREMISE")
   DETAIL
    reply->multum_routes[d.seq].ignore_ind = 1
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
