CREATE PROGRAM dcp_get_all_working_views:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 working_view_id = f8
     2 position_cd = f8
     2 location_cd = f8
     2 display_name = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 version_num = i4
     2 current_working_view = f8
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
 DECLARE currentver_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM working_view wv
  WHERE wv.working_view_id > 0
  ORDER BY wv.position_cd, wv.location_cd, wv.display_name,
   wv.version_num DESC
  HEAD wv.position_cd
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].working_view_id = wv.working_view_id, reply->qual[counter].position_cd = wv
   .position_cd, reply->qual[counter].location_cd = wv.location_cd,
   reply->qual[counter].display_name = wv.display_name, reply->qual[counter].active_ind = wv
   .active_ind, reply->qual[counter].beg_effective_dt_tm = wv.beg_effective_dt_tm,
   reply->qual[counter].end_effective_dt_tm = wv.end_effective_dt_tm, reply->qual[counter].
   version_num = wv.version_num, reply->qual[counter].current_working_view = wv.current_working_view,
   currentver_ind = 1
  HEAD wv.location_cd
   IF (currentver_ind != 1)
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(reply->qual,(counter+ 9))
    ENDIF
    reply->qual[counter].working_view_id = wv.working_view_id, reply->qual[counter].position_cd = wv
    .position_cd, reply->qual[counter].location_cd = wv.location_cd,
    reply->qual[counter].display_name = wv.display_name, reply->qual[counter].active_ind = wv
    .active_ind, reply->qual[counter].beg_effective_dt_tm = wv.beg_effective_dt_tm,
    reply->qual[counter].end_effective_dt_tm = wv.end_effective_dt_tm, reply->qual[counter].
    version_num = wv.version_num, reply->qual[counter].current_working_view = wv.current_working_view,
    currentver_ind = 1
   ENDIF
  HEAD wv.display_name
   IF (currentver_ind != 1)
    counter = (counter+ 1)
    IF (mod(counter,10)=1)
     stat = alterlist(reply->qual,(counter+ 9))
    ENDIF
    reply->qual[counter].working_view_id = wv.working_view_id, reply->qual[counter].position_cd = wv
    .position_cd, reply->qual[counter].location_cd = wv.location_cd,
    reply->qual[counter].display_name = wv.display_name, reply->qual[counter].active_ind = wv
    .active_ind, reply->qual[counter].beg_effective_dt_tm = wv.beg_effective_dt_tm,
    reply->qual[counter].end_effective_dt_tm = wv.end_effective_dt_tm, reply->qual[counter].
    version_num = wv.version_num, reply->qual[counter].current_working_view = wv.current_working_view
   ENDIF
  DETAIL
   currentver_ind = 0
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
