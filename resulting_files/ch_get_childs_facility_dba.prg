CREATE PROGRAM ch_get_childs_facility:dba
 RECORD reply(
   1 parent_loc_cd = f8
   1 parent_loc_desc = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.code_value
  FROM location_group l,
   code_value c
  PLAN (l
   WHERE (l.child_loc_cd=request->location_cd)
    AND l.active_ind=1
    AND l.root_loc_cd=0)
   JOIN (c
   WHERE c.code_value=l.parent_loc_cd
    AND c.cdf_meaning IN ("FACILITY", "BUILDING", "NURSEUNIT", "CLINIC", "AMBULATORY",
   "APPTLOC", "ROOM", "WAITROOM", "CHECKOUT")
    AND c.active_ind=1)
  DETAIL
   reply->parent_loc_cd = c.code_value, reply->parent_loc_desc = c.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
