CREATE PROGRAM ec_profiler_m24:dba
 DECLARE dfacilitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE dpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg1,
   location_group lg2,
   order_action oa,
   orders o,
   prsnl p
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
   JOIN (o
   WHERE o.person_id=ti.person_id
    AND ((o.encntr_id+ 0)=ti.encntr_id)
    AND ((o.orig_ord_as_flag+ 0)=2)
    AND ((o.catalog_type_cd+ 0)=dpharmacy)
    AND o.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm)
   )
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
   JOIN (lg1
   WHERE lg1.child_loc_cd=tg.parent_value
    AND lg1.location_group_type_cd=dbuildingcd
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=dfacilitycd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
  ORDER BY lg2.parent_loc_cd, p.position_cd, o.encntr_id
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, encntrcnt = 0
  HEAD o.encntr_id
   encntrcnt = (encntrcnt+ 1)
  FOOT  p.position_cd
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(encntrcnt))
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
