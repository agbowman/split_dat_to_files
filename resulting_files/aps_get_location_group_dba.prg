CREATE PROGRAM aps_get_location_group:dba
 RECORD reply(
   1 qual[*]
     2 location_type_cd = f8
     2 location_type_disp = c40
     2 location_type_desc = vc
     2 location_type_mean = c12
     2 location[*]
       3 location_cd = f8
       3 location_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET loc_cnt = cnvtint(size(request->qual,5))
 SET count = 0
 SET stat = alterlist(reply->qual,loc_cnt)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   (dummyt d  WITH seq = value(loc_cnt))
  PLAN (d)
   JOIN (c
   WHERE c.code_set=222
    AND (c.cdf_meaning=request->qual[d.seq].meaning)
    AND c.active_ind=1)
  DETAIL
   reply->qual[d.seq].location_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  l.location_cd
  FROM location_group g,
   location l,
   (dummyt d  WITH seq = value(loc_cnt))
  PLAN (d)
   JOIN (g
   WHERE (g.parent_loc_cd=request->parent_loc_cd)
    AND g.active_ind=1
    AND g.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND g.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (l
   WHERE g.child_loc_cd=l.location_cd
    AND (l.location_type_cd=reply->qual[d.seq].location_type_cd)
    AND l.location_cd != 0.0
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY l.location_type_cd, l.location_cd, 0
  HEAD REPORT
   count = 0
  HEAD l.location_type_cd
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,5)=1)
    stat = alterlist(reply->qual[d.seq].location,(count+ 4))
   ENDIF
   reply->qual[d.seq].location[count].location_cd = l.location_cd
  FOOT  l.location_type_cd
   stat = alterlist(reply->qual[d.seq].location,count)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LOCATION_GROUP"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
#exit_script
END GO
