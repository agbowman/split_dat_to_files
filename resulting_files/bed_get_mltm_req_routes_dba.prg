CREATE PROGRAM bed_get_mltm_req_routes:dba
 FREE SET reply
 RECORD reply(
   1 routes[*]
     2 route_id = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_output_route dor
  WHERE dor.dcp_output_route_id > 0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->routes,(cnt+ 9))
   ENDIF
   reply->routes[cnt].route_id = dor.dcp_output_route_id, reply->routes[cnt].description = dor
   .route_description
  FOOT REPORT
   stat = alterlist(reply->routes,cnt)
  WITH counter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
