CREATE PROGRAM ec_profiler_m61:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dfacilitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE desicomm = f8 WITH constant(uar_get_code_by("MEANING",6006,"ESIDEFAULT"))
 FREE RECORD commtypes
 RECORD commtypes(
   1 qualcnt = i4
   1 qual[*]
     2 communication_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   code_value cv
  PLAN (cve
   WHERE cve.code_set=6006
    AND cve.field_name="skip_cosign_ind"
    AND cve.field_value="1")
   JOIN (cv
   WHERE cv.code_value=cve.code_value
    AND cv.active_ind=1
    AND cv.display_key != "WRITTEN"
    AND cv.code_value != desicomm)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), commtypes->qualcnt = cnt, stat = alterlist(commtypes->qual,cnt),
   commtypes->qual[cnt].communication_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg,
   location_group lg2,
   orders o,
   order_action oa
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.child_value=0
    AND tg.tracking_group_cd=cv.code_value)
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (lg
   WHERE lg.child_loc_cd=tg.parent_value
    AND lg.location_group_type_cd=dbuildingcd
    AND lg.root_loc_cd=0
    AND lg.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.location_group_type_cd=dfacilitycd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (o
   WHERE o.person_id=ti.person_id
    AND o.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm)
    AND ((o.encntr_id+ 0)=ti.encntr_id)
    AND ((o.template_order_id+ 0)=0))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1
    AND oa.order_provider_id > 0.0
    AND expand(idx,1,commtypes->qualcnt,oa.communication_type_cd,commtypes->qual[idx].
    communication_type_cd)
    AND oa.communication_type_cd > 0.0
    AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND oa.action_dt_tm BETWEEN tc.checkin_dt_tm AND tc.checkout_dt_tm)
  ORDER BY lg2.parent_loc_cd, o.order_id
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, ordercnt = 0
  HEAD o.order_id
   ordercnt = (ordercnt+ 1)
  FOOT  lg2.parent_loc_cd
   detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
   facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt].
    positions[1].details,detailcnt),
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
     ordercnt))
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
