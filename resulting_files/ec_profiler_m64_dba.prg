CREATE PROGRAM ec_profiler_m64:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE desicomm = f8 WITH constant(uar_get_code_by("MEANING",6006,"ESIDEFAULT"))
 FREE RECORD commtypes
 RECORD commtypes(
   1 qualcnt = i4
   1 qual[*]
     2 communication_type_cd = f8
 )
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=6006
    AND cv.active_ind=1
    AND cv.code_value != desicomm)
   JOIN (cve
   WHERE cve.code_value=outerjoin(cv.code_value)
    AND cve.field_name=outerjoin("skip_cosign_ind"))
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (((cve.field_value IN ("0", "", null)) OR (((cve.code_value=0.0) OR (cv.display_key="WRITTEN"
   )) )) )
    cnt = (cnt+ 1), commtypes->qualcnt = cnt, stat = alterlist(commtypes->qual,cnt),
    commtypes->qual[cnt].communication_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
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
  FOOT REPORT
   stat = alterlist(ipenctypes->qual,cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl"
  FROM orders o,
   order_action oa,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_sequence=1
    AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND ((oa.order_id+ 0) > 0.0)
    AND expand(idx2,1,commtypes->qualcnt,oa.communication_type_cd,commtypes->qual[idx2].
    communication_type_cd)
    AND oa.communication_type_cd > 0.0
    AND ((oa.order_provider_id+ 0) > 0.0))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm)
    AND ((o.template_order_id+ 0)=0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
    encntr_type_cd)
    AND elh.active_ind=1)
  ORDER BY elh.loc_facility_cd, o.order_id
  HEAD elh.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, ordercnt = 0
  HEAD o.order_id
   ordercnt = (ordercnt+ 1)
  FOOT  elh.loc_facility_cd
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
