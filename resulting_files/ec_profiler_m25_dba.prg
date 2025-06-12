CREATE PROGRAM ec_profiler_m25:dba
 RECORD loc_group_type(
   1 facility = f8
   1 building = f8
 )
 SET loc_group_type->facility = uar_get_code_by("MEANING",222,"FACILITY")
 SET loc_group_type->building = uar_get_code_by("MEANING",222,"BUILDING")
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg1,
   location_group lg2,
   order_compliance oc
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.tracking_group_cd=cv.code_value
    AND tg.child_table="TRACK_ASSOC")
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (lg1
   WHERE lg1.child_loc_cd=tg.parent_value
    AND (lg1.location_group_type_cd=loc_group_type->building)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND (lg2.location_group_type_cd=loc_group_type->facility)
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (oc
   WHERE oc.encntr_id=ti.encntr_id
    AND oc.performed_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND oc.performed_dt_tm BETWEEN tc.checkin_dt_tm AND tc.checkout_dt_tm)
  ORDER BY lg2.parent_loc_cd
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, positioncnt = (reply->facilities[
   facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
   positioncnt].capability_in_use_ind = 1
  WITH nocounter
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
