CREATE PROGRAM dcp_get_facility_by_org:dba
 RECORD reply(
   1 organization_id = f8
   1 location[*]
     2 location_cd = f8
     2 location_disp = vc
     2 location_desc = vc
     2 location_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 DECLARE loc_type_cd = f8 WITH noconstant
 SET loc_type_cd = uar_get_code_by("MEANING",222,"FACILITY")
 IF (loc_type_cd=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM location l
  WHERE (l.organization_id=request->organization_id)
   AND l.active_ind=1
   AND l.location_type_cd=loc_type_cd
  ORDER BY l.organization_id
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->location,5))
    stat = alterlist(reply->location,(ncnt+ 10))
   ENDIF
   reply->location[ncnt].location_cd = l.location_cd, reply->location[ncnt].location_type_cd =
   loc_type_cd,
   CALL echo(build("location_cd is:",l.location_cd))
  FOOT REPORT
   stat = alterlist(reply->location,ncnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
