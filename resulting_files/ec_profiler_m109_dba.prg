CREATE PROGRAM ec_profiler_m109:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dpharm = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE dordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   order_product op,
   encntr_loc_hist elh,
   prsnl p
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND oa.order_status_cd=dordered
    AND oa.needs_verify_ind=3)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.catalog_type_cd=dpharm
    AND ((o.template_order_id+ 0)=0))
   JOIN (op
   WHERE op.order_id=o.order_id)
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND elh.end_effective_dt_tm >= oa.action_dt_tm)
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
  ORDER BY elh.loc_facility_cd, p.position_cd, op.order_id
  HEAD elh.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (positioncnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt, stat =
   alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, resultcnt = 0
  HEAD op.order_id
   resultcnt = (resultcnt+ 1)
  FOOT  p.position_cd
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(resultcnt))
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
