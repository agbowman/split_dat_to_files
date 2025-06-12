CREATE PROGRAM cr_del_chart_route:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sequence_group_ids(
   1 qual[*]
     2 id = f8
 )
 SET route_cnt = size(request->chart_routes,5)
 FOR (i = 1 TO route_cnt)
   DELETE  FROM chart_seq_group_reltn csgr
    WHERE csgr.sequence_group_id IN (
    (SELECT
     csg.sequence_group_id
     FROM chart_sequence_group csg
     WHERE (csg.chart_route_id=request->chart_routes[i].id)
     WITH nocounter))
    WITH nocounter
   ;end delete
 ENDFOR
 DELETE  FROM chart_sequence_group csg,
   (dummyt d  WITH seq = value(route_cnt))
  SET csg.seq = 1
  PLAN (d)
   JOIN (csg
   WHERE (csg.chart_route_id=request->chart_routes[d.seq].id))
  WITH nocounter
 ;end delete
 DELETE  FROM chart_route cr,
   (dummyt d  WITH seq = value(route_cnt))
  SET cr.seq = 1
  PLAN (d)
   JOIN (cr
   WHERE (cr.chart_route_id=request->chart_routes[d.seq].id))
  WITH nocounter
 ;end delete
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
