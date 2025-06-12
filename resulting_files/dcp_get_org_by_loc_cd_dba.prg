CREATE PROGRAM dcp_get_org_by_loc_cd:dba
 RECORD reply(
   1 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 DECLARE failed = c1
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM location l
  WHERE (l.location_cd=request->location_cd)
   AND l.active_ind=1
  DETAIL
   reply->organization_id = l.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errmsg = concat("Organization not found for a given location_cd: ",cnvtstring(request->
    location_cd))
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.operationname = "SELECT"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.status = "Z"
  SET reply->status_data.targetobjectname = "ErrorMessage"
  SET reply->status_data.targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
