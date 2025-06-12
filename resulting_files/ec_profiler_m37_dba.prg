CREATE PROGRAM ec_profiler_m37:dba
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=dipencclass)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=71
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ipenctypes->qual,(cnt+ 9))
   ENDIF
   ipenctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    orders o,
    order_action oa
   PLAN (oa
    WHERE oa.action_sequence=1
     AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (o
    WHERE o.order_id=oa.order_id
     AND ((o.template_order_id+ 0)=0))
    JOIN (elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND oa.action_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   ORDER BY elh.loc_facility_cd, o.catalog_type_cd, o.order_id
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
    position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
    reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
    positions[1].capability_in_use_ind = 1
   HEAD o.catalog_type_cd
    ordercnt = 0
   HEAD o.order_id
    ordercnt = (ordercnt+ 1)
   FOOT  o.catalog_type_cd
    detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
    facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt]
     .positions[1].details,detailcnt),
    reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = uar_get_code_display
    (o.catalog_type_cd), reply->facilities[facilitycnt].positions[1].details[detailcnt].
    detail_value_txt = trim(cnvtstring(ordercnt))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
