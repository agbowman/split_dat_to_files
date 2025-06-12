CREATE PROGRAM ec_profiler_m43:dba
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE dauthcd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
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
  SELECT INTO "nl"
   FROM encntr_loc_hist elh,
    dcp_forms_activity dfa,
    dcp_forms_ref dfr
   PLAN (dfa
    WHERE dfa.last_activity_dt_tm >= cnvtdatetime(request->start_dt_tm)
     AND dfa.form_status_cd=dauthcd
     AND dfa.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
     AND dfr.active_ind=1)
    JOIN (elh
    WHERE elh.encntr_id=dfa.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND dfa.last_activity_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1)
   ORDER BY elh.loc_facility_cd, dfr.dcp_forms_ref_id, dfa.dcp_forms_activity_id
   HEAD REPORT
    faciltycnt = 0
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, positioncnt = (reply->
    facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt =
    positioncnt,
    stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
    facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
    positioncnt].capability_in_use_ind = 1
   HEAD dfr.dcp_forms_ref_id
    formscnt = 0, detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[1].detail_cnt = detailcnt,
    stat = alterlist(reply->facilities[facilitycnt].positions[1].details,detailcnt)
   HEAD dfa.dcp_forms_activity_id
    formscnt = (formscnt+ 1)
   FOOT  dfr.dcp_forms_ref_id
    reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = dfr.definition,
    reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = cnvtstring(
     formscnt)
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
