CREATE PROGRAM ec_profiler_m23:dba
 DECLARE idx1 = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE dcomplete = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE dbuilding = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 FREE RECORD med_hold
 RECORD med_hold(
   1 qual[*]
     2 code_value = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning="MED"
   AND cv.active_ind=1
  HEAD REPORT
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(med_hold->qual,icnt), med_hold->qual[icnt].code_value = cv
   .code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg1,
   location_group lg2,
   task_activity ta
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE (tg.tracking_group_cd=(cv.code_value+ 0))
    AND tg.child_table="TRACK_ASSOC")
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (ta
   WHERE ta.encntr_id=ti.encntr_id
    AND expand(idx1,1,size(med_hold->qual,5),ta.task_type_cd,med_hold->qual[idx1].code_value)
    AND ta.task_status_cd=dcomplete
    AND ta.task_dt_tm >= tc.checkin_dt_tm
    AND ta.task_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND ta.task_dt_tm <= tc.checkout_dt_tm
    AND ta.task_dt_tm <= cnvtdatetime(request->stop_dt_tm))
   JOIN (lg1
   WHERE (lg1.child_loc_cd=(tg.parent_value+ 0))
    AND ((lg1.root_loc_cd+ 0)=0)
    AND lg1.active_ind=1
    AND lg1.location_group_type_cd=dbuilding)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND ((lg2.root_loc_cd+ 0)=0)
    AND lg2.active_ind=1)
  ORDER BY lg2.parent_loc_cd, ta.encntr_id
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, positioncnt = (reply->facilities[
   facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
   positioncnt].capability_in_use_ind = 1,
   encntrcnt = 0
  HEAD ta.encntr_id
   encntrcnt = (encntrcnt+ 1)
  FOOT  lg2.parent_loc_cd
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
