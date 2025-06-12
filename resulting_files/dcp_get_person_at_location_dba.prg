CREATE PROGRAM dcp_get_person_at_location:dba
 SET modify = predeclare
 RECORD reply(
   1 person_id = f8
   1 encounter_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE personcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM encntr_domain e
  WHERE datetimecmp(e.end_effective_dt_tm,cnvtdatetime("31-DEC-2100"))=0
   AND (e.loc_facility_cd=request->facility_cd)
   AND (e.loc_building_cd=request->building_cd)
   AND (e.loc_nurse_unit_cd=request->nurse_unit_cd)
   AND (e.loc_room_cd=request->room_cd)
   AND (e.loc_bed_cd=request->bed_cd)
   AND e.active_ind=1
  DETAIL
   personcnt = (personcnt+ 1), reply->person_id = e.person_id, reply->encounter_id = e.encntr_id
  WITH nocounter
 ;end select
 IF ((reply->person_id > 0)
  AND personcnt=1)
  SET reply->status_data.status = "S"
 ELSE
  IF (personcnt > 0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_GET_PERSON_AT_LOCATION"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "MULTIPLE ROWS RETURNED"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
