CREATE PROGRAM bbd_get_don_locn:dba
 RECORD reply(
   1 parentlist[*]
     2 location_cd = f8
     2 location_cd_disp = c40
     2 location_cd_desc = vc
     2 location_cd_mean = c12
     2 childlist[*]
       3 location_cd = f8
       3 location_cd_disp = c40
       3 location_cd_desc = vc
       3 location_cd_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET location_type_code_set = 222
 SET count1 = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET location_group_type_cd = 0.0
 SET parent_location_cd = 0.0
 SET child_location_cd = 0.0
 SET parentcount = 0
 SET childcount = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=222
   AND (c.cdf_meaning=request->location_group_type_mean)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   location_group_type_cd = c.code_value
  WITH counter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get location_group_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_get_inv_area"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "Could not retrieve location_group_type_cd for request->location_group_type_mean-",request->
   location_group_type_mean)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lg1.parent_loc_cd
  FROM location_group lg1
  PLAN (lg1
   WHERE lg1.location_group_type_cd=location_group_type_cd
    AND (((request->parent_loc_cd=0.0)) OR ((request->parent_loc_cd > 0.0)
    AND (lg1.parent_loc_cd=request->parent_loc_cd)))
    AND lg1.active_ind=1
    AND (lg1.active_status_cd=reqdata->active_status_cd)
    AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY lg1.parent_loc_cd, lg1.child_loc_cd
  DETAIL
   IF (lg1.parent_loc_cd != parent_location_cd)
    parent_location_cd = lg1.parent_loc_cd, child_location_cd = 0, parentcount = (parentcount+ 1),
    childcount = 0, stat = alterlist(reply->parentlist,parentcount), reply->parentlist[parentcount].
    location_cd = lg1.parent_loc_cd
   ENDIF
   childcount = (childcount+ 1), stat = alterlist(reply->parentlist[parentcount].childlist,childcount
    ), reply->parentlist[parentcount].childlist[childcount].location_cd = lg1.child_loc_cd
  WITH counter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "T"
 ENDIF
END GO
